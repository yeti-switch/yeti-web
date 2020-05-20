# frozen_string_literal: true

FactoryBot.define do
  factory :gateway_group, class: GatewayGroup do
    sequence(:name) { |n| "gateway_group_#{n}" }
    balancing_mode_id { 2 }
    association :vendor, factory: :contractor, vendor: true
  end
end
