# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_throttling_profiles
#
#  id        :integer(2)       not null, primary key
#  codes     :string           not null, is an Array
#  name      :string           not null
#  threshold :float(24)        not null
#  window    :integer(2)       not null
#
# Indexes
#
#  gateway_throttling_profiles_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :gateway_throttling_profile, class: 'Equipment::GatewayThrottlingProfile' do
    sequence(:name) { |n| "Throttling profile #{n}" }
    sequence(:codes) { [Equipment::GatewayThrottlingProfile::CODE_503] }
    sequence(:threshold) { 80 }
    sequence(:window) { 60 }
  end
end
