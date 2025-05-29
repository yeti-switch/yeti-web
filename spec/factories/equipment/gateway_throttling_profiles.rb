# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_throttling_profiles
#
#  id              :integer(2)       not null, primary key
#  codes           :string           not null, is an Array
#  minimum_calls   :integer(2)       default(20), not null
#  name            :string           not null
#  threshold_end   :float(24)        not null
#  threshold_start :float(24)        not null
#  window          :integer(2)       not null
#
# Indexes
#
#  gateway_throttling_profiles_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :gateway_throttling_profile, class: 'Equipment::GatewayThrottlingProfile' do
    sequence(:name) { |n| "Throttling profile #{n}" }
    codes { [Equipment::GatewayThrottlingProfile::CODE_503] }
    threshold_start { 60 }
    threshold_end { 90 }
    window { 60 }
    minimum_calls { 210 }
  end
end
