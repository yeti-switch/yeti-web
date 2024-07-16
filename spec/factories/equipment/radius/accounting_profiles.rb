# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.radius_accounting_profiles
#
#  id                          :integer(2)       not null, primary key
#  attempts                    :integer(2)       default(2), not null
#  enable_interim_accounting   :boolean          default(FALSE), not null
#  enable_start_accounting     :boolean          default(FALSE), not null
#  enable_stop_accounting      :boolean          default(TRUE), not null
#  interim_accounting_interval :integer(2)       default(30), not null
#  name                        :string           not null
#  port                        :integer(4)       not null
#  secret                      :string           not null
#  server                      :string           not null
#  timeout                     :integer(2)       default(100), not null
#
# Indexes
#
#  radius_accounting_profiles_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :accounting_profile, class: 'Equipment::Radius::AccountingProfile' do
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
