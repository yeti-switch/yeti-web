FactoryGirl.define do
  factory :rateplan, class: Rateplan do
    sequence(:name) { |n| "rateplan#{n}" }
    association :profit_control_mode, factory: :rate_profit_control_mode
  end
end
