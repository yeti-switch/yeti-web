# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: Payment do
    amount { 10 }
    association :account
    notes { 'notes text' }
    private_notes { 'private notes' }
    status_id { Payment::CONST::STATUS_ID_COMPLETED }
    type_id { Payment::CONST::TYPE_ID_MANUAL }

    after(:create) do |record|
      record.reload # to populate uuid
    end

    trait :pending do
      type_id { Payment::CONST::TYPE_ID_CRYPTOMUS }
      status_id { Payment::CONST::STATUS_ID_PENDING }
    end

    trait :canceled do
      type_id { Payment::CONST::TYPE_ID_CRYPTOMUS }
      status_id { Payment::CONST::STATUS_ID_CANCELED }
    end

    trait :cryptomus_completed do
      type_id { Payment::CONST::TYPE_ID_CRYPTOMUS }
      status_id { Payment::CONST::STATUS_ID_COMPLETED }
    end
  end
end
