# frozen_string_literal: true

FactoryGirl.define do
  factory :gateway_group, class: GatewayGroup do
    sequence(:name) { |n| "gateway_group_#{n}" }
    prefer_same_pop true

    association :vendor, factory: :contractor, vendor: true
  end
end
