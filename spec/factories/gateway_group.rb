FactoryGirl.define do
  factory :gateway_group, class: GatewayGroup do
    vendor_id nil
    name nil
    prefer_same_pop true
  end
end
