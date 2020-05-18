# frozen_string_literal: true

# == Schema Information
#
# Table name: balance_notifications
#
#  id           :integer          not null, primary key
#  created_at   :datetime         not null
#  is_processed :boolean          default(FALSE), not null
#  processed_at :datetime
#  direction    :string
#  action       :string
#  data         :json
#

FactoryBot.define do
  factory :balance_notification, class: Log::BalanceNotification do
    created_at { Time.now.utc }
    is_processed { false }
    action { 'clear' }
  end
end
