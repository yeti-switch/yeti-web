# frozen_string_literal: true

FactoryGirl.define do
  factory :rateplan, class: Rateplan do
    sequence(:name) { |n| "rateplan#{n}" }

    factory :rateplan_with_customer do
      after(:create) do |record|
        create :customers_auth, rateplan: record
      end
    end
  end
end
