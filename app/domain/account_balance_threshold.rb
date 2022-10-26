# frozen_string_literal: true

class AccountBalanceThreshold
  class << self
    def accounts_required_notification
      Account.balance_threshold_notification_required.preload(:balance_notification_setting)
    end
  end

  def initialize(account)
    @account = account
  end

  def check_threshold
    ApplicationRecord.transaction do
      if state_low_threshold? && !low_threshold_reached?
        create_balance_notification(Log::BalanceNotification::CONST::EVENT_ID_LOW_THRESHOLD_CLEARED)
        NotificationEvent.low_threshold_cleared(account)

      elsif state_high_threshold? && !high_threshold_reached?
        create_balance_notification(Log::BalanceNotification::CONST::EVENT_ID_HIGH_THRESHOLD_CLEARED)
        NotificationEvent.high_threshold_cleared(account)
      end

      if !state_low_threshold? && low_threshold_reached?
        create_balance_notification(Log::BalanceNotification::CONST::EVENT_ID_LOW_THRESHOLD_REACHED)
        NotificationEvent.low_threshold_reached(account)

      elsif !state_high_threshold? && high_threshold_reached?
        create_balance_notification(Log::BalanceNotification::CONST::EVENT_ID_HIGH_THRESHOLD_REACHED)
        NotificationEvent.high_threshold_reached(account)
      end

      balance_notification_setting.update!(state_id: calculate_current_state_id)
    end
  end

  private

  attr_reader :account
  delegate :balance_notification_setting, to: :account
  delegate :state_low_threshold?, :state_high_threshold?, :state_none?, to: :balance_notification_setting
  delegate :low_threshold_reached?, :high_threshold_reached?, to: :balance_notification_setting

  def create_balance_notification(event_id)
    Log::BalanceNotification.create!(
      event_id: event_id,
      account: account,
      account_balance: account.balance,
      balance_low_threshold: balance_notification_setting.low_threshold,
      balance_high_threshold: balance_notification_setting.high_threshold
    )
  end

  def calculate_current_state_id
    if low_threshold_reached?
      AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
    elsif high_threshold_reached?
      AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
    else
      AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
    end
  end
end
