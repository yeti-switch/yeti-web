# frozen_string_literal: true

class ManualInvoiceForm < ApplicationForm
  def self.policy_class
    Billing::InvoicePolicy
  end

  with_model_name 'Invoice'
  attribute :account_id, :integer
  attribute :start_date, :string
  attribute :end_date, :string

  attr_writer :contractor_id
  attr_reader :model
  delegate :id, to: :model, allow_nil: true

  validates :account, presence: true
  validate :validate_generated_invoices
  validate :validate_start_end_time

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
    return if start_date.blank?

    timezone = account_time_zone
    return if timezone.nil?

    timezone.parse(start_date)
  }

  # @!method end_time
  define_memoizable :end_time, apply: lambda {
    return if end_date.blank?

    timezone = account_time_zone
    return if timezone.nil?

    timezone.parse(end_date)
  }

  private

  def account_time_zone
    return if account.nil?

    ActiveSupport::TimeZone.new(account.timezone)
  end

  def validate_generated_invoices
    return if account.nil?

    errors.add(:account, 'have invoices auto generation enabled') if account.next_invoice_at.present?
  end

  def validate_covered_invoices
    start_time_server = start_time.in_time_zone(Time.zone)

    covered_invoices = Billing::Invoice
                       .where(account_id: account.id)
                       .where('end_date >= ?', start_time_server)

    errors.add(:base, 'there are invoice(s) within provided period') if covered_invoices.any?
  end

  def validate_start_end_time
    errors.add(:start_date, :blank) if start_date.blank?
    errors.add(:end_date, :blank) if end_date.blank?

    timezone = account_time_zone
    return if timezone.nil?

    errors.add(:start_date, :invalid) if start_date.present? && start_time.nil?
    errors.add(:end_date, :invalid) if end_date.present? && end_time.nil?
    errors.add(:end_date, 'must be greater than start date') if end_time && start_time && end_time < start_time
  end

  def _save
    @model = BillingInvoice::Create.call(
        account: account,
        start_time: start_time,
        end_time: end_time,
        type_id: Billing::InvoiceType::MANUAL
      )
    Worker::FillInvoiceJob.perform_later(@model.id)
    @model
  rescue BillingInvoice::Create::Error => e
    errors.add(:base, e.message)
  rescue Worker::FillInvoiceJob => e
    errors.add(:base, e.message)
  end
end
