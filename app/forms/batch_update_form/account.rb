# frozen_string_literal: true

class BatchUpdateForm::Account < BatchUpdateForm::Base
  model_class 'Account'
  attribute :contractor_id, type: :foreign_key, class_name: 'Contractor'
  attribute :min_balance
  attribute :max_balance
  attribute :vat
  attribute :balance_low_threshold
  attribute :balance_high_threshold
  attribute :destination_rate_limit
  attribute :origination_capacity
  attribute :termination_capacity
  attribute :total_capacity
  attribute :max_call_duration
  attribute :vendor_invoice_period_id, type: :foreign_key, class_name: 'Billing::InvoicePeriod'
  attribute :customer_invoice_period_id, type: :foreign_key, class_name: 'Billing::InvoicePeriod'
  attribute :vendor_invoice_template_id, type: :foreign_key, class_name: 'Billing::InvoiceTemplate'
  attribute :customer_invoice_template_id, type: :foreign_key, class_name: 'Billing::InvoiceTemplate'
  attribute :timezone_id, type: :foreign_key, class_name: 'System::Timezone'

  validates :min_balance, required_with: :max_balance, if: -> { min_balance.nil? || max_balance.nil? }

  # presence
  validates :vat, presence: true, if: :vat_changed?
  validates :min_balance, presence: true, if: :min_balance_changed?
  validates :max_balance, presence: true, if: :max_balance_changed?
  validates :timezone_id, presence: true, if: :timezone_id_changed?

  # numericality
  validates :balance_low_threshold, required_with: :balance_high_threshold
  validates :min_balance, numericality: { allow_blank: true }, if: :min_balance_changed?
  validates :max_balance, numericality: {
    allow_blank: true,
    greater_than_or_equal_to: :min_balance
  }, if: -> { :max_balance_changed? && min_balance =~ /^[0-9]+$/ }

  validates :termination_capacity, numericality: {
    greater_than: 0,
    less_than_or_equal_to: Yeti::ActiveRecord::PG_MAX_SMALLINT,
    allow_blank: true,
    only_integer: true,
    allow_nil: true
  }, if: :termination_capacity_changed?
  validates :origination_capacity, numericality: {
    greater_than: 0,
    less_than_or_equal_to: Yeti::ActiveRecord::PG_MAX_SMALLINT,
    allow_blank: true,
    only_integer: true
  }, if: :origination_capacity_changed?
  validates :total_capacity, numericality: {
    greater_than: 0,
    less_than_or_equal_to: Yeti::ActiveRecord::PG_MAX_SMALLINT,
    allow_blank: true,
    only_integer: true
  }, if: :total_capacity_changed?
  validates :vat, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    allow_blank: true
  }, if: :vat_changed?
  validates :destination_rate_limit, numericality: {
    greater_than_or_equal_to: 0,
    allow_blank: true,
    allow_nil: true
  }, if: :destination_rate_limit_changed?
  validates :max_call_duration, numericality: {
    greater_than: 0,
    allow_blank: true,
    only_integer: true,
    allow_nil: true
  }, if: :max_call_duration_changed?
  validates :balance_low_threshold, numericality: { allow_blank: true }, if: :balance_low_threshold_changed?
  validates :balance_high_threshold, numericality: {
    greater_than_or_equal_to: :balance_low_threshold
  }, if: -> { balance_high_threshold.present? && balance_low_threshold =~ /^[0-9]+$/ }
end
