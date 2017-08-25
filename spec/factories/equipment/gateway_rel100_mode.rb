FactoryGirl.define do
  factory :gateway_rel100_mode, class: Equipment::GatewayRel100Mode do
    sequence(:name) { |n| "gateway_rel_100_mode#{n}" }
  end
end
