# frozen_string_literal: true

FactoryBot.define do
  factory :accounting_profile, class: Equipment::Radius::AccountingProfile do
    sequence(:name) { |n| "profile#{n}" }
    server { 'server' }
    port { '1' }
    secret { 'secret' }
    timeout { 100 }
    attempts { 2 }

    trait :filled do
      after(:create) do |record|
        FactoryBot.create_list(:gateway, 2, radius_accounting_profile: record)
        FactoryBot.create_list(:accounting_profile_stop_attribute, 2, profile: record)
        FactoryBot.create_list(:accounting_profile_start_attribute, 2, profile: record)
        FactoryBot.create_list(:customers_auth, 2, radius_accounting_profile: record)
      end
    end
  end
end
