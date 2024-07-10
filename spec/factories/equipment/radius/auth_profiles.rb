# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.radius_auth_profiles
#
#  id              :integer(2)       not null, primary key
#  attempts        :integer(2)       default(2), not null
#  name            :string           not null
#  port            :integer(4)       not null
#  reject_on_error :boolean          default(TRUE), not null
#  secret          :string           not null
#  server          :string           not null
#  timeout         :integer(2)       default(100), not null
#
# Indexes
#
#  radius_auth_profiles_name_key  (name) UNIQUE
#
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
