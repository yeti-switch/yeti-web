FactoryGirl.define do
  factory :rate_profit_control_mode, class: Routing::RateProfitControlMode do
    sequence(:id, 10)
    sequence(:name) { |n| "rate profit control mode #{n}"}
  end
end
