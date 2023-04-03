# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: Payment do
    amount { 10 }
    association :account
    notes { 'notes text' }
    private_notes { 'private notes' }

    after(:create) do |record|
      record.reload # to populate uuid
    end
  end
end
