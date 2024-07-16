# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.account_balance_notification_settings
#
#  id             :bigint(8)        not null, primary key
#  high_threshold :decimal(, )
#  low_threshold  :decimal(, )
#  send_to        :integer(4)       is an Array
#  account_id     :bigint(8)        not null
#  state_id       :integer(2)       default(0), not null
#
# Indexes
#
#  account_balance_notification_settings_account_id_uniq_idx  (account_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_f185d22f87  (account_id => accounts.id)
#
FactoryBot.define do
  factory :account_balance_notification_setting, class: 'AccountBalanceNotificationSetting' do
  end
end
