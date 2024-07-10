# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.countries
#
#  id   :integer(4)       not null, primary key
#  iso2 :string(2)        not null
#  name :string           not null
#
# Indexes
#
#  countries_name_key  (name) UNIQUE
#
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
