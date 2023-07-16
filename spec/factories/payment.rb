# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: Payment do
    amount { 10 }
    association :account
    notes { 'notes text' }
    private_notes { 'private notes' }
    status_id { Payment::CONST::STATUS_ID_COMPLETED }

    after(:create) do |record|
      record.reload # to populate uuid
    end

    trait :pending do
      status_id { Payment::CONST::STATUS_ID_PENDING }
    end

    trait :canceled do
      status_id { Payment::CONST::STATUS_ID_CANCELED }
    end
  end
end
