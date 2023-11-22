# frozen_string_literal: true

class AccountForm < ProxyForm
  def self.policy_class
    AccountPolicy
  end

  with_model_name 'Account'
  model_class 'Account'

  attribute :balance_low_threshold, :decimal
  attribute :balance_high_threshold, :decimal
  attribute :send_balance_notifications_to, :integer, array: true

  model_attributes :name,
                   :contractor_id,
                   :min_balance,
                   :max_balance,
                   :vat,
                   :destination_rate_limit,
                   :max_call_duration,
                   :origination_capacity,
                   :termination_capacity,
                   :total_capacity,
                   :invoice_period_id,
                   :invoice_template_id,
                   :send_invoices_to,
                   :timezone_id,
                   :uuid,
                   :invoice_ref_template

  validate :validate_balance_thresholds

  after_initialize :assign_from_balance_notification_setting
  before_save :apply_invoice_period
  after_save :save_balance_notification_setting

  def send_invoices_to=(value)
    model.send_invoices_to = Array.wrap(value).reject(&:blank?).presence
  end

  private

  def apply_invoice_period
    return unless invoice_period_id_changed?

    if invoice_period_id
      invoice_params = BillingInvoice::CalculatePeriod::Current.call(account: model)
      model.next_invoice_at = invoice_params[:end_time]
      model.next_invoice_type_id = invoice_params[:type_id]
    else
      model.next_invoice_at = nil
      model.next_invoice_type_id = nil
    end
  end

  def assign_from_balance_notification_setting
    model.build_balance_notification_setting if model.balance_notification_setting.nil?
    self.balance_low_threshold = model.balance_notification_setting.low_threshold
    self.balance_high_threshold = model.balance_notification_setting.high_threshold
    self.send_balance_notifications_to = model.balance_notification_setting.send_to
  end

  def save_balance_notification_setting
    model.build_balance_notification_setting if model.balance_notification_setting.nil?
    model.balance_notification_setting.update!(
      low_threshold: balance_low_threshold,
      high_threshold: balance_high_threshold,
      send_to: send_balance_notifications_to.reject(&:nil?).presence
    )
  end

  def validate_balance_thresholds
    return if balance_low_threshold.nil? || balance_high_threshold.nil?

    if balance_low_threshold >= balance_high_threshold
      errors.add(:balance_low_threshold, 'must be less than Balance high threshold')
    end
  end
end
