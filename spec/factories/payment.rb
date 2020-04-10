# frozen_string_literal: true

FactoryGirl.define do
  factory :payment, class: Payment do
    amount 10
    association :account
    notes 'notes text'
  end
end
