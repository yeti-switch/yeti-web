# frozen_string_literal: true

FactoryBot.define do
  factory :invoice, class: Billing::Invoice do
    start_date { 7.days.ago.utc }
    end_date { 1.day.ago.utc }
    state_id { Billing::InvoiceState::NEW }
    type_id { Billing::InvoiceType::MANUAL }

    after(:build) do |record, _ev|
      record.contractor_id ||= record.account&.contractor_id
    end

    trait :vendor do
      vendor_invoice { true }
    end

    trait :customer do
      vendor_invoice { false }
    end

    trait :manual do
      type_id { Billing::InvoiceType::MANUAL }
    end

    trait :auto_full do
      type_id { Billing::InvoiceType::AUTO_FULL }
    end

    trait :auto_partial do
      type_id { Billing::InvoiceType::AUTO_FULL }
    end

    trait :new do
      state_id { Billing::InvoiceState::NEW }
    end

    trait :pending do
      state_id { Billing::InvoiceState::PENDING }
    end

    trait :approved do
      state_id { Billing::InvoiceState::APPROVED }
    end

    trait :with_vendor_account do
      account { FactoryBot.create(:account, contractor: FactoryBot.create(:vendor)) }
    end

    after(:create) do |record|
      record.update!(reference: record.id.to_s) if record.reference.blank?
    end
  end
end
