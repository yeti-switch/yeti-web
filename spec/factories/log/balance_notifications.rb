# frozen_string_literal: true

# == Schema Information
#
# Table name: logs.balance_notifications
#
#  id                     :bigint(8)        not null, primary key
#  account_balance        :decimal(, )      not null
#  balance_high_threshold :decimal(, )
#  balance_low_threshold  :decimal(, )
#  created_at             :timestamptz      not null
#  account_id             :integer(4)       not null
#  event_id               :integer(2)       not null
#
# Indexes
#
#  balance_notifications_account_id_idx  (account_id)
#

FactoryBot.define do
  factory :balance_notification, class: Log::BalanceNotification do
    created_at { Time.now.utc }
    event_id { Log::BalanceNotification::CONST::EVENT_ID_HIGH_THRESHOLD_CLEARED }

    trait :with_account do
      account { FactoryBot.create(:account) }
    end

    after(:build) do |record|
      record.account_balance ||= record.account&.balance
    end
  end
end
