# frozen_string_literal: true

FactoryGirl.define do
  factory :contact, class: Billing::Contact do
    sequence(:email) { |n| "rspec_mail_#{n}@example.com" }

    association :contractor, factory: :customer

    trait :filled do
      association :contractor, factory: :customer
      admin_user { build(:admin_user, :filled) }
    end
  end
end
