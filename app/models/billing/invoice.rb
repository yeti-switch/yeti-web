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

  validates :contractor, :account, :end_date, :start_date, presence: true

  has_paper_trail class_name: 'AuditLogItem'

  scope :for_customer, -> { where vendor_invoice: false }
  scope :for_vendor, -> { where vendor_invoice: true }
  scope :approved, -> { where state_id: Billing::InvoiceState::APPROVED }
  scope :pending, -> { where state_id: Billing::InvoiceState::PENDING }
  scope :new_invoices, -> { where state_id: Billing::InvoiceState::NEW }

  after_initialize do
    if new_record?
      self.amount ||= 0
      self.calls_count ||= 0
      self.calls_duration ||= 0
      self.billing_duration ||= 0
      self.state_id = Billing::InvoiceState::NEW
    end
  end

  def display_name
    "Invoice #{id}"
  end

  def direction
    vendor_invoice? ? 'Vendor' : 'Customer'
  end

  # todo service
  def approve
    transaction do
      update!(state_id: Billing::InvoiceState::APPROVED)
      send_email
    end
  end

  def approvable?
    Billing::InvoiceState::PENDING == state_id
  end

  def regenerate_document_allowed?
    Billing::InvoiceState::PENDING == state_id
  end

  # todo service
  def regenerate_document
    transaction do
      invoice_document&.delete
      begin
        BillingInvoice::GenerateDocument.call(invoice: self)
      rescue BillingInvoice::GenerateDocument::TemplateUndefined => e
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
  # todo service
  def send_email
    invoice_document&.send_invoice
  end
end
