# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.amount_round_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  amount_round_modes_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :cdr_price_round_mode, class: 'System::CdrPriceRoundMode' do
    sequence(:id, &:n)
    sequence(:name) { |n| "Always UP #{n}" }

    trait :always_up do
      id { 2 }
      name { 'Always UP' }
    end
  end
end
