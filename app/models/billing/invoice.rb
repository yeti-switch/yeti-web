# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                       :integer(4)       not null, primary key
#  amount                   :decimal(, )      not null
#  billing_duration         :bigint(8)        not null
#  calls_count              :bigint(8)        not null
#  calls_duration           :bigint(8)        not null
#  end_date                 :datetime         not null
#  first_call_at            :datetime
#  first_successful_call_at :datetime
#  last_call_at             :datetime
#  last_successful_call_at  :datetime
#  start_date               :datetime         not null
#  successful_calls_count   :bigint(8)
#  vendor_invoice           :boolean          default(FALSE), not null
#  created_at               :datetime         not null
#  account_id               :integer(4)       not null
#  contractor_id            :integer(4)
#  state_id                 :integer(2)       default(1), not null
#  type_id                  :integer(2)       not null
#
# Foreign Keys
#
#  invoices_state_id_fkey  (state_id => invoice_states.id)
#  invoices_type_id_fkey   (type_id => invoice_types.id)
#

class Billing::Invoice < Cdr::Base
  has_many :vendor_cdrs, -> { where vendor_invoice: true }, class_name: 'Cdr', foreign_key: 'vendor_invoice_id'
  has_many :customer_cdrs, -> { where vendor_invoice: false }, class_name: 'Cdr', foreign_key: 'customer_invoice_id'

  belongs_to :account, class_name: 'Account', foreign_key: 'account_id'
  belongs_to :contractor, class_name: 'Contractor', foreign_key: :contractor_id # , :conditions => {:customer => true}act
  belongs_to :state, class_name: 'Billing::InvoiceState', foreign_key: :state_id
  belongs_to :type, class_name: 'Billing::InvoiceType', foreign_key: :type_id

  has_one :invoice_document, dependent: :destroy
  has_many :full_destinations, class_name: 'Billing::InvoiceDestination', foreign_key: :invoice_id, dependent: :delete_all
  has_many :full_networks, class_name: 'Billing::InvoiceNetwork', foreign_key: :invoice_id, dependent: :delete_all
  has_many :destinations, -> { where('successful_calls_count>0') }, class_name: 'Billing::InvoiceDestination', foreign_key: :invoice_id
  has_many :networks, -> { where('successful_calls_count>0') }, class_name: 'Billing::InvoiceNetwork', foreign_key: :invoice_id

  before_destroy do
    cdrs = Cdr::Cdr.where('time_start >= ? AND time_start <= ? ', start_date, end_date)
    if vendor_invoice
      cdrs.where(vendor_invoice_id: id).update_all(vendor_invoice_id: nil)
    else
      cdrs.where(customer_invoice_id: id).update_all(customer_invoice_id: nil)
    end
  end

  validates :contractor, :account, :end_date, :start_date, presence: true

  has_paper_trail class_name: 'AuditLogItem'

  scope :for_customer, -> { where vendor_invoice: false }
  scope :for_vendor, -> { where vendor_invoice: true }
  scope :approved, -> { where state_id: Billing::InvoiceState::APPROVED }
  scope :pending, -> { where state_id: Billing::InvoiceState::PENDING }

  before_create do
    execute_sp('SET LOCAL TIMEZONE TO ?', account.timezone.name)
  end

  # after_create do
  #   execute_sp("SELECT * FROM billing.invoice_generate(?)", self.id)
  # end

  after_create do
    execute_sp('lock table billing.invoices in exclusive mode') # see ticket #108
    # we need lock customer-vendor pair. Now I use lock table for this - this is dirty workaround
    # But we just need prevent vendor's invoice generation if any customer's invoice was generating now and vice versa

    if start_date.nil?
      previous_invoice = Billing::Invoice.where(account_id: account_id).order('end_date desc').limit(1).take
      raise "Can't detect date start" if previous_invoice.nil?

      self.start_date = previous_invoice.end_date
    end

    if vendor_invoice # vendor invoice
      generate_vendor_data
    else # customer invoice
      generate_customer_data
    end

    detalize_invoice
  end

  after_initialize do
    if new_record?
      self.amount ||= 0
      self.calls_count ||= 0
      self.calls_duration ||= 0
      self.billing_duration ||= 0
    end
  end

  def cdr_filter_for_invoice
    "time_start=>'#{start_date.strftime('%Y-%m-%d %H%M%S.%L')}' AND time_end <'#{end_date.strftime('%Y-%m-%d %H%M%S.%L')}'"
  end

  def display_name
    "Invoice #{id}"
  end

  def direction
    vendor_invoice? ? 'Vendor' : 'Customer'
  end

  def approve
    self.state_id = Billing::InvoiceState::APPROVED
    save
    send_email
  end

  def approvable?
    Billing::InvoiceState::PENDING == state_id
  end

  def regenerate_document_allowed?
    Billing::InvoiceState::PENDING == state_id
  end

  def regenerate_document
    transaction do
      invoice_document&.delete
      begin
        InvoiceDocs.new(self).save!
      rescue InvoiceDocs::TemplateUndefined => e
        Rails.logger.info { e.message }
      end
    end
  end

  def invoice_period
    if vendor_invoice?
      account.vendor_invoice_period
    else
      account.customer_invoice_period
    end
  end

  def odt_template
    if vendor_invoice?
      account.vendor_invoice_template
    else
      account.customer_invoice_template
    end
  end

  def file_name
    "#{id}_#{start_date}_#{end_date}"
  end

  Totals = Struct.new(:total_amount, :total_calls_count, :total_calls_duration, :total_billing_duration)

  def self.totals
    row = extending(ActsAsTotalsRelation).totals_row_by(
      'sum(amount) as total_amount',
      'sum(calls_count) as total_calls_count',
      'sum(calls_duration) as total_calls_duration',
      'sum(billing_duration) as total_billing_duration'
    )
    Totals.new(*row)
  end

  delegate :contacts_for_invoices, to: :account

  def subject
    display_name
  end

  # FIX this copy paste
  def send_email
    invoice_document&.send_invoice
  end

  private

  def generate_vendor_data
    SqlCaller::Cdr.execute(
      "INSERT INTO billing.invoice_destinations(
            dst_prefix, country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            first_successful_call_at,
            last_call_at,
            last_successful_call_at
          ) SELECT
            dialpeer_prefix, dst_country_id, dst_network_id, dialpeer_next_rate,
            COUNT(id),  -- calls count
            COUNT(NULLIF(success,false)),  -- successful_calls_count
            SUM(duration), -- calls_duration
            SUM(vendor_duration), -- billing_duration
            SUM(vendor_price), -- amount
            ?, -- invoice_id
            MIN(time_start), -- first_call_at
            MIN(CASE success WHEN true THEN time_start ELSE NULL END), -- first_successful_call_at
            MAX(time_start), -- last_call_at
            MAX(CASE success WHEN true THEN time_start ELSE NULL END) -- last_successful_call_at
          FROM (
            SELECT *
            FROM cdr.cdr
            WHERE
              vendor_acc_id =? AND
              time_start>=? AND
              time_start<?
          ) invoice_data
          GROUP BY dialpeer_prefix, dst_country_id, dst_network_id, dialpeer_next_rate",
      id,
      account_id,
      start_date,
      end_date
    )

    SqlCaller::Cdr.execute(
      "INSERT INTO billing.invoice_networks(
            country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            first_successful_call_at,
            last_call_at,
            last_successful_call_at
          ) SELECT
            country_id, network_id, rate,
            SUM(calls_count),
            SUM(successful_calls_count),
            SUM(calls_duration),
            SUM(billing_duration),
            SUM(amount),
            ?, -- invoice_id
            MIN(first_call_at),
            MIN(first_successful_call_at),
            MAX(last_call_at),
            MAX(last_successful_call_at)
          FROM billing.invoice_destinations
          WHERE invoice_id=?
          GROUP BY country_id, network_id, rate",
      id,
      id
    )
  end

  def generate_customer_data
    SqlCaller::Cdr.execute(
      "INSERT INTO billing.invoice_destinations(
            dst_prefix, country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            first_successful_call_at,
            last_call_at,
            last_successful_call_at
          ) SELECT
            destination_prefix, dst_country_id, dst_network_id, destination_next_rate,
            COUNT(NULLIF(is_last_cdr,false)), -- calls_count
            COUNT(NULLIF((success AND is_last_cdr),false)),  -- successful_calls_count
            SUM(duration), -- calls_duration
            SUM(customer_duration), -- billing_duration
            SUM(customer_price), -- amount
            ?, -- invoice_id
            MIN(time_start), -- first_call_at
            MIN(CASE success WHEN true THEN time_start ELSE NULL END), -- first_successful_call_at
            MAX(time_start), -- last_call_at
            MAX(CASE success WHEN true THEN time_start ELSE NULL END) -- last_successful_call_at
          FROM (
            SELECT *
            FROM cdr.cdr
            WHERE
              customer_acc_id =? AND
              time_start >=? AND
              time_start < ?
          ) invoice_data
          GROUP BY destination_prefix, dst_country_id, dst_network_id, destination_next_rate",
      id,
      account_id,
      start_date,
      end_date
    )

    SqlCaller::Cdr.execute(
      "INSERT INTO billing.invoice_networks(
            country_id, network_id, rate,
            calls_count,
            successful_calls_count,
            calls_duration,
            billing_duration,
            amount,
            invoice_id,
            first_call_at,
            first_successful_call_at,
            last_call_at,
            last_successful_call_at
          ) SELECT
            country_id, network_id, rate,
            SUM(calls_count),
            SUM(successful_calls_count),
            SUM(calls_duration),
            SUM(billing_duration),
            SUM(amount),
            ?, -- invoice_id
            MIN(first_call_at),
            MIN(first_successful_call_at),
            MAX(last_call_at),
            MAX(last_successful_call_at)
          FROM billing.invoice_destinations
          WHERE invoice_id=?
          GROUP BY country_id, network_id, rate",
      id,
      id
    )
  end

  def detalize_invoice
    data = destinations.summary
    self.amount = data.amount
    self.calls_count = data.calls_count
    self.successful_calls_count = data.successful_calls_count
    self.calls_duration = data.calls_duration
    self.billing_duration = data.billing_duration
    self.first_call_at = data.first_call_at
    self.first_successful_call_at = data.first_successful_call_at
    self.last_call_at = data.last_call_at
    self.last_successful_call_at = data.last_successful_call_at
    save!
  end
end
