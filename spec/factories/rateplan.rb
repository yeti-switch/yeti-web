# frozen_string_literal: true

FactoryGirl.define do
  factory :rateplan, class: Rateplan do
    sequence(:name) { |n| "rateplan#{n}" }

    trait :with_uuid do
      uuid { SecureRandom.uuid }
    end

    factory :rateplan_with_customer do
      after(:create) do |record|
        create :customers_auth, rateplan: record
      end
    end

    trait :filled do
      association :profit_control_mode, factory: :rate_profit_control_mode
      customers_auths { build_list :customers_auth, 2 }
      destinations { build_list :destination, 2 }
      with_uuid
    end
  end
end
