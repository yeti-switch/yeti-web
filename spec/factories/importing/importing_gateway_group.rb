# frozen_string_literal: true

FactoryGirl.define do
  factory :importing_gateway_group, class: Importing::GatewayGroup do
    o_id nil
    name nil
    vendor_name nil
    vendor_id nil
    prefer_same_pop true
    error_string nil
  end
end
