# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.currencies
#
#  id               :integer(2)       not null, primary key
#  name             :string           not null
#  rate             :float            not null
#  rate_provider_id :integer(2)
#
# Indexes
#
#  currencies_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :currency, class: 'Billing::Currency' do
    sequence(:name) do |n|
      pool = Billing::Currency::NAMES.keys - %w[USD USDT]
      pool[n % pool.size]
    end
    rate { 1.5 }

    trait :default do
      initialize_with { Billing::Currency.find(0) }
    end
  end
end
