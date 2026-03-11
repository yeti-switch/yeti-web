# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.currencies
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#  rate :float            not null
#
# Indexes
#
#  currencies_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :currency, class: 'Billing::Currency' do
    sequence(:name) { |n| Billing::Currency::NAMES.keys[n % Billing::Currency::NAMES.size] }
    rate { 1.5 }

    trait :default do
      id { 0 }
      name { 'USD' }
      rate { 1 }
    end
  end
end
