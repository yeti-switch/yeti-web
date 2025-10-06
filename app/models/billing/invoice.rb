# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoices
#
#  id                                :integer(4)       not null, primary key
#  amount_earned                     :decimal(, )      default(0.0), not null
#  amount_spent                      :decimal(, )      default(0.0), not null
#  amount_total                      :decimal(, )      default(0.0), not null
#  end_date                          :timestamptz      not null
#  first_originated_call_at          :timestamptz
#  first_terminated_call_at          :timestamptz
#  last_originated_call_at           :timestamptz
#  last_terminated_call_at           :timestamptz
#  originated_amount_earned          :decimal(, )      default(0.0), not null
#  originated_amount_spent           :decimal(, )      default(0.0), not null
#  originated_billing_duration       :bigint(8)        default(0), not null
#  originated_calls_count            :bigint(8)        default(0), not null
#  originated_calls_duration         :bigint(8)        default(0), not null
#  originated_successful_calls_count :bigint(8)        default(0), not null
#  reference                         :string
#  service_transactions_count        :integer(4)       default(0), not null
#  services_amount_earned            :decimal(, )      default(0.0), not null
#  services_amount_spent             :decimal(, )      default(0.0), not null
#  start_date                        :timestamptz      not null
#  terminated_amount_earned          :decimal(, )      default(0.0), not null
#  terminated_amount_spent           :decimal(, )      default(0.0), not null
#  terminated_billing_duration       :integer(4)       default(0), not null
#  terminated_calls_count            :integer(4)       default(0), not null
#  terminated_calls_duration         :integer(4)       default(0), not null
#  terminated_successful_calls_count :integer(4)       default(0), not null
#  uuid                              :uuid             not null
#  created_at                        :timestamptz      not null
#  account_id                        :integer(4)       not null
#  contractor_id                     :integer(4)
#  state_id                          :integer(2)       default(3), not null
#  type_id                           :integer(2)       not null
#
# Indexes
#
#  index_billing.invoices_on_reference  (reference)
#

class Billing::Invoice < Cdr::Base
  self.table_name = 'billing.invoices'
  self.inheritance_column = :_type_disabled

  include WithPaperTrail

  Totals = Struct.new(
    :total_amount_total,
    :total_amount_spent,
    :total_amount_earned,
    :total_originated_amount_spent,
    :total_originated_amount_earned,
    :total_originated_calls_count,
    :total_originated_calls_duration,
    :total_originated_billing_duration,
    :total_terminated_amount_spent,
    :total_terminated_amount_earned,
    :total_terminated_calls_count,
    :total_terminated_calls_duration,
    :total_terminated_billing_duration,
    :total_services_amount_spent,
    :total_services_amount_earned,
    :total_service_transactions_count
  )

  class << self
    def totals
      row = extending(ActsAsTotalsRelation).totals_row_by(
        'sum(amount_total) as total_amount_total',
        'sum(amount_spent) as total_amount_spent',
        'sum(amount_earned) as total_amount_earned',
        'sum(originated_amount_spent) as total_originated_amount_spent',
        'sum(originated_amount_earned) as total_originated_amount_earned',
        'sum(originated_calls_count) as total_originated_calls_count',
        'sum(originated_calls_duration) as total_originated_calls_duration',
        'sum(originated_billing_duration) as total_originated_billing_duration',
        'sum(terminated_amount_spent) as total_terminated_amount_spent',
        'sum(terminated_amount_earned) as total_terminated_amount_earned',
        'sum(terminated_calls_count) as total_terminated_calls_count',
        'sum(terminated_calls_duration) as total_terminated_calls_duration',
        'sum(terminated_billing_duration) as total_terminated_billing_duration',
        'sum(services_amount_spent) as total_services_amount_spent',
        'sum(services_amount_earned) as total_services_amount_earned',
        'sum(service_transactions_count) as total_service_transactions_count'
      )
      Totals.new(*row)
    end

    def last_end_date(account_id:)
      Billing::Invoice.where(account_id: account_id).order('end_date desc').limit(1).pick(:end_date)
    end
  end

  composed_of :state,
              class_name: 'Billing::InvoiceState',
              mapping: { state_id: :id },
              constructor: ->(state_id) { Billing::InvoiceState.find(state_id) }

  composed_of :type,
              class_name: 'Billing::InvoiceType',
              mapping: { type_id: :id },
              constructor: ->(type_id) { Billing::InvoiceType.find(type_id) }

  has_many :vendor_cdrs, class_name: 'Cdr::Cdr', foreign_key: 'vendor_invoice_id'
  has_many :customer_cdrs, class_name: 'Cdr::Cdr', foreign_key: 'customer_invoice_id'

  belongs_to :account, class_name: 'Account', foreign_key: 'account_id'
  belongs_to :contractor, class_name: 'Contractor', foreign_key: :contractor_id, optional: true # , :conditions => {:customer => true}act

  has_one :invoice_document, dependent: :destroy
  has_many :originated_destinations, class_name: 'Billing::InvoiceOriginatedDestination', foreign_key: :invoice_id, dependent: :delete_all
  has_many :terminated_destinations, class_name: 'Billing::InvoiceTerminatedDestination', foreign_key: :invoice_id, dependent: :delete_all
  has_many :originated_networks, class_name: 'Billing::InvoiceOriginatedNetwork', foreign_key: :invoice_id, dependent: :delete_all
  has_many :terminated_networks, class_name: 'Billing::InvoiceTerminatedNetwork', foreign_key: :invoice_id, dependent: :delete_all
  has_many :service_data, class_name: 'Billing::InvoiceServiceData', foreign_key: :invoice_id, dependent: :delete_all

  validates :contractor,
            :account,
            :end_date,
            :start_date,
            :state,
            :type,
            presence: true

  validates :state_id, inclusion: { in: Billing::InvoiceState.ids }, allow_nil: true
  validates :type_id, inclusion: { in: Billing::InvoiceType.ids }, allow_nil: true

  validate :validate_dates
  validates :amount_spent, :amount_earned,
            :originated_amount_spent, :originated_amount_earned,
            :terminated_amount_spent, :terminated_amount_earned, numericality: { greater_than_or_equal_to: 0 }

  validates :originated_billing_duration,
            :originated_calls_count,
            :originated_calls_duration,
            :terminated_billing_duration,
            :terminated_calls_count,
            :terminated_calls_duration,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :approved, -> { where state_id: Billing::InvoiceState::APPROVED }
  scope :pending, -> { where state_id: Billing::InvoiceState::PENDING }
  scope :new_invoices, -> { where state_id: Billing::InvoiceState::NEW }

  scope :cover_period, lambda { |start_date, end_date|
    where '(start_date < ? AND end_date > ?) OR (start_date >= ? AND start_date < ?)',
          start_date,
          start_date,
          start_date,
          end_date
  }

  def display_name
    "Invoice #{id}"
  end

  def approvable?
    state.pending?
  end

  def regenerate_document_allowed?
    state.pending?
  end

  # todo service
  def regenerate_document
    transaction do
      invoice_document&.delete
      begin
        BillingInvoice::GenerateDocument.call(invoice: self)
      rescue BillingInvoice::GenerateDocument::TemplateUndefined => e
        Rails.logger.info { "#{e.class}: #{e.message}" }
      end
    end
  end

  def file_name
    "#{id}_#{start_date}_#{end_date}"
  end

  delegate :contacts_for_invoices, :invoice_period, to: :account

  def subject
    display_name
  end

  private

  def validate_dates
    errors.add(:start_date, :blank) if start_date.blank?
    errors.add(:end_date, :blank) if end_date.blank?

    if start_date && end_date && start_date >= end_date
      errors.add(:end_date, 'must be greater than start_date')
    end
  end
end
