FactoryGirl.define do
  factory :rate_profit_control_mode, class: Routing::RateProfitControlMode do
    sequence(:id, 10)
    name 'rate profit control mode'
  end
end
