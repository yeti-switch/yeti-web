# frozen_string_literal: true

FactoryBot.define do
  factory :rate_group, class: Routing::RateGroup do
    sequence(:name) { |n| "rateplan#{n}" }
    sequence(:external_id)

    trait :filled do
      destinations { build_list :destination, 2 }
    end

  end

end
