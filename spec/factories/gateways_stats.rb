# frozen_string_literal: true

# == Schema Information
#
# Table name: gateways_stats
#
#  id             :integer(4)       not null, primary key
#  acd            :float
#  asr            :float
#  calls          :bigint(8)        not null
#  calls_fail     :bigint(8)        not null
#  calls_success  :bigint(8)        not null
#  locked_at      :timestamptz
#  total_duration :bigint(8)        not null
#  unlocked_at    :timestamptz
#  created_at     :timestamptz      not null
#  updated_at     :timestamptz      not null
#  gateway_id     :integer(4)       not null
#
# Indexes
#
#  unique_gw  (gateway_id) UNIQUE
#
FactoryBot.define do
  factory :gateways_stat, class: 'GatewaysStat' do
    gateway
    created_at { Time.now.utc }
    updated_at { 1.hour.ago.utc }
    calls { 6 }
    calls_success { 5 }
    calls_fail { 1 }
    total_duration { 200 }
  end
end
