# frozen_string_literal: true

FactoryBot.define do
  factory :contractor, class: Contractor do
    sequence(:name) { |n| "contractor#{n}" }
    enabled { true }
    vendor { false }
    customer { false }

    factory :customer do
      vendor { false }
      customer { true }
    end

    factory :vendor do
      vendor { true }
      customer { false }
    end
  end
end
