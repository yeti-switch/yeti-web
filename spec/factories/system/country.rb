# frozen_string_literal: true

FactoryBot.define do
  factory :country, class: System::Country do
    name { 'United States' }
    iso2 { 'US' }

    trait :uniq_name do
      sequence(:name) { |n| "Ukraine_#{n}" }
    end

    trait :filled do
      prefixes { build_list :network_prefix, 2, country: self }
      networks { build_list :network, 2, :uniq_name, :filled }
    end

    factory :country_uniq, traits: [:uniq_name]
  end
end
