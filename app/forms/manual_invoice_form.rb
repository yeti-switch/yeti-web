# frozen_string_literal: true

class ManualInvoiceForm < ApplicationForm
  def self.policy_class
    Billing::InvoicePolicy
  end

  with_model_name 'Invoice'
  attribute :account_id, :integer
  attribute :start_date, :string
  attribute :end_date, :string
  attribute :is_vendor, :boolean, default: false

  attr_writer :contractor_id
  attr_reader :invoice
  delegate :id, to: :invoice, allow_nil: true

  validates :account, presence: true
  validate :validate_generated_invoices
  validates :start_time, :end_time, presence: true
  validate :validate_end_time
  validates :is_vendor, inclusion: { in: [true, false] }

  def persisted?
    id.present?
  end

  def contractor_id
    account&.contractor_id
  end

  # @!method account
  define_memoizable :account, apply: lambda {
    return if account_id.nil?

    Account.find_by(id: account_id)
  }

  # @!method start_time
  define_memoizable :start_time, apply: lambda {
    return if account.nil? || start_date.blank?

    account.timezone.time_zone.parse(start_date)
  }

  # @!method end_time
  define_memoizable :end_time, apply: lambda {
    return if account.nil? || end_date.blank?

    account.timezone.time_zone.parse(end_date)
  }

  private

  def validate_generated_invoices
    return if account.nil?

    if is_vendor && account.next_vendor_invoice_at.present?
      errors.add(:account, 'have vendor invoices auto generation enabled')
    end

    if !is_vendor && account.next_customer_invoice_at.present?
      errors.add(:account, 'have customer invoices auto generation enabled')
    end
  end

  def validate_covered_invoices
    start_time_server = start_time.in_time_zone(Time.zone)

    covered_invoices = Billing::Invoice
                       .where(account_id: account.id, vendor_invoice: is_vendor)
                       .where('end_date >= ?', start_time_server)

    errors.add(:base, 'there are invoice(s) within provided period') if covered_invoices.any?
  end

  def validate_end_time
    return if end_time.nil? || start_time.nil?

    errors.add(:end_date, 'must be greater than start date') if end_time < start_time
  end

  def _save
    BillingInvoice::Create.call(
        account: account,
        is_vendor: is_vendor,
        start_time: start_time,
        end_time: end_time,
        type_id: Billing::InvoiceType::MANUAL
      )
  rescue BillingInvoice::Create::Error => e
    errors.add(:base, e.message)
  end
end
