# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.amount_round_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

FactoryGirl.define do
  factory :cdr_price_round_mode, class: System::CdrPriceRoundMode do
    sequence(:id, &:n)
    sequence(:name) { |n| "Always UP #{n}" }

    trait :always_up do
      id 2
      name 'Always UP'
    end
  end
end
