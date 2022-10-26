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
                   :vendor_invoice_period_id,
                   :customer_invoice_period_id,
                   :vendor_invoice_template_id,
                   :customer_invoice_template_id,
                   :send_invoices_to,
                   :timezone_id,
                   :uuid,
                   :customer_invoice_ref_template,
                   :vendor_invoice_ref_template

  validate :validate_balance_thresholds

  before_save :apply_vendor_invoice_period
  before_save :apply_customer_invoice_period
  before_save :sync_balance_notification_setting

  private

  def apply_customer_invoice_period
    return unless customer_invoice_period_id_changed?

    if customer_invoice_period_id

      invoice_params = BillingInvoice::CalculatePeriod::Current.call(account: model, is_vendor: false)
      model.next_customer_invoice_at = invoice_params[:end_time]
      model.next_customer_invoice_type_id = invoice_params[:type_id]
    else
      model.next_customer_invoice_at = nil
      model.next_customer_invoice_type_id = nil
    end
  end

  def apply_vendor_invoice_period
    return unless vendor_invoice_period_id_changed?

    if vendor_invoice_period_id
      invoice_params = BillingInvoice::CalculatePeriod::Current.call(account: model, is_vendor: true)
      model.next_vendor_invoice_at = invoice_params[:end_time]
      model.next_vendor_invoice_type_id = invoice_params[:type_id]
    else
      model.next_vendor_invoice_at = nil
      model.next_vendor_invoice_type_id = nil
    end
  end

  def sync_balance_notification_setting
    setting = model.balance_notification_setting || model.build_balance_notification_setting
    setting.assign_attributes(
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
