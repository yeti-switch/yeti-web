# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id            :bigint(8)        not null, primary key
#  amount        :decimal(, )      not null
#  notes         :string
#  private_notes :string
#  uuid          :uuid             not null
#  created_at    :timestamptz      not null
#  account_id    :integer(4)       not null
#  status_id     :integer(2)       default(20), not null
#  type_id       :integer(2)       default(20), not null
#
# Indexes
#
#  payments_account_id_idx  (account_id)
#  payments_uuid_key        (uuid) UNIQUE
#
# Foreign Keys
#
#  payments_account_id_fkey  (account_id => accounts.id)
#
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
