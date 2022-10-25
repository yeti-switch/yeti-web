# frozen_string_literal: true

module AdminApi
  class AccountForm < ProxyForm
    with_model_name 'Account'
    model_class 'Account'

    model_attributes :name,
                     :balance,
                     :min_balance,
                     :max_balance,
                     :destination_rate_limit,
                     :max_call_duration,
                     :external_id,
                     :uuid,
                     :origination_capacity,
                     :termination_capacity,
                     :total_capacity,
                     :send_invoices_to,
                     :contractor_id,
                     :timezone_id,
                     :customer_invoice_period_id,
                     :vendor_invoice_period_id,
                     :customer_invoice_template_id,
                     :vendor_invoice_template_id

    attribute :balance_low_threshold, :decimal
    attribute :balance_high_threshold, :decimal
    attribute :send_balance_notifications_to, :integer, array: true

    after_initialize :assign_from_balance_notification_setting
    validate :validate_balance_thresholds
    before_save :assign_to_balance_notification_setting
    before_save :apply_vendor_invoice_period
    before_save :apply_customer_invoice_period

    def send_invoices_to=(value)
      model.send_invoices_to = Array.wrap(value)
    end

    def send_balance_notifications_to=(value)
      super Array.wrap(value)
    end

    private

    def assign_from_balance_notification_setting
      model.build_balance_notification_setting if model.new_record?

      self.balance_low_threshold = model.balance_notification_setting.low_threshold
      self.balance_high_threshold = model.balance_notification_setting.high_threshold
      self.send_balance_notifications_to = model.balance_notification_setting.send_to
    end

    def assign_to_balance_notification_setting
      model.balance_notification_setting.assign_attributes(
        low_threshold: balance_low_threshold,
        high_threshold: balance_high_threshold,
        send_to: send_balance_notifications_to.reject(&:nil?).presence
      )
    end

    def validate_balance_thresholds
      return if balance_low_threshold.nil? || balance_high_threshold.nil?

      if balance_low_threshold >= balance_high_threshold
        errors.add(:balance_low_threshold, 'must be less than balance high threshold')
      end
    end

    def apply_customer_invoice_period
      return unless model.customer_invoice_period_id_changed?

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
      return unless model.vendor_invoice_period_id_changed?

      if vendor_invoice_period_id
        invoice_params = BillingInvoice::CalculatePeriod::Current.call(account: model, is_vendor: true)
        model.next_vendor_invoice_at = invoice_params[:end_time]
        model.next_vendor_invoice_type_id = invoice_params[:type_id]
      else
        model.next_vendor_invoice_at = nil
        model.next_vendor_invoice_type_id = nil
      end
    end
  end
end
