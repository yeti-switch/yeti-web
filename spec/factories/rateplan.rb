FactoryGirl.define do
  factory :rateplan, class: Rateplan do
    sequence(:name) { |n| "rateplan#{n}" }
    association :profit_control_mode, factory: :rate_profit_control_mode

    factory :rateplan_with_customer do
      after(:create) do |record|
        create :customers_auth, rateplan: record
      end
    end
  end
end
