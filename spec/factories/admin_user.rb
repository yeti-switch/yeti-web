# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user do
    sequence(:username) { |n| "admin#{n}" }
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { '111111' }
    roles { ['user'] }
    after(:build) do |admin|
      if admin.class.ldap?
        admin.encrypted_password = admin.encrypt_password(admin.password)
      end
    end

    trait :filled do
      association :billing_contact, factory: :contact
    end
  end
end