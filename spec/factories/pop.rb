# frozen_string_literal: true

FactoryBot.define do
  factory :pop, class: Pop do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "Point of presence #{n}" }

    trait :filled do
      after(:create) do |record|
        create_list(:node, 2, pop: record)
        create_list(:customers_auth, 2, pop: record)
        create_list(:gateway, 2, pop: record)
      end
    end
  end
end
