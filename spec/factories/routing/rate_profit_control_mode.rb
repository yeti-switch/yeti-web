# frozen_string_literal: true

FactoryGirl.define do
  factory :rate_profit_control_mode, class: Routing::RateProfitControlMode do
    sequence(:id) { |n| n + 100 }
    sequence(:name) { |n| "rate_profit_control_mode#{n}" }
  end
end
