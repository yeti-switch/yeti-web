# frozen_string_literal: true

FactoryBot.define do
  factory :rateplan, class: Routing::Rateplan do
    sequence(:name) { |n| "rateplan#{n}" }

    profit_control_mode_id { Routing::RateProfitControlMode::MODE_PER_CALL }

    trait :with_uuid do
      uuid { SecureRandom.uuid }
    end

    factory :rateplan_with_customer do
      after(:create) do |record|
        create :customers_auth, rateplan: record
      end
    end

    trait :filled do
      customers_auths { build_list :customers_auth, 2 }
      rate_groups { build_list :rate_group, 2 }
      with_uuid
    end
  end
end
