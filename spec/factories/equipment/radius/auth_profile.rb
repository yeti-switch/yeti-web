# frozen_string_literal: true

FactoryBot.define do
  factory :auth_profile, class: Equipment::Radius::AuthProfile do
    sequence(:name) { |n| "auth_profile#{n}" }
    server { 'server' }
    port { '1' }
    secret { 'secret' }
    timeout { 100 }
    attempts { 2 }

    trait :filled do
      after(:create) do |record|
        create_list(:customers_auth, 2, radius_auth_profile: record)
      end
    end
  end
end
