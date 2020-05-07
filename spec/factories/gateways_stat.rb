# frozen_string_literal: true

# == Schema Information
#
# Table name: gateways_stats
#
#  id             :integer          not null, primary key
#  gateway_id     :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  calls          :integer          not null
#  calls_success  :integer          not null
#  calls_fail     :integer          not null
#  total_duration :integer          not null
#  asr            :float
#  acd            :float
#  locked_at      :datetime
#  unlocked_at    :datetime
#

FactoryGirl.define do
  factory :gateways_stat, class: GatewaysStat do
    gateway
    created_at Time.now.utc
    updated_at 1.hour.ago.utc
    calls 6
    calls_success 5
    calls_fail 1
    total_duration 200
  end
end
