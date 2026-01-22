# frozen_string_literal: true

module AdminApi
  class AccountForm < ProxyForm
    with_model_name 'Account'
    model_class 'Account'

    model_attributes :name,
                     :vat,
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
                     :timezone,
                     :invoice_template_id,
                     :invoice_period_id

    attribute :balance_low_threshold, :decimal
    attribute :balance_high_threshold, :decimal
    attribute :send_balance_notifications_to, :integer, array: true

    after_initialize :assign_from_model
    validate :validate_balance_thresholds
    after_save :save_balance_notification_setting

    def send_invoices_to=(value)
      model.send_invoices_to = Array.wrap(value).reject(&:blank?).presence
    end

    def send_balance_notifications_to=(value)
      super Array.wrap(value)
    end

    private

    def assign_from_model
      model.build_balance_notification_setting if model.balance_notification_setting.nil?
      self.balance_low_threshold = model.balance_notification_setting.low_threshold
      self.balance_high_threshold = model.balance_notification_setting.high_threshold
      self.send_balance_notifications_to = model.balance_notification_setting.send_to
    end

    def save_balance_notification_setting
      model.balance_notification_setting.update!(
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
  end
end
