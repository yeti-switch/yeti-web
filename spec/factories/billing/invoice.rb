# frozen_string_literal: true

FactoryGirl.define do
  factory :invoice, class: Billing::Invoice do
    transient do
      _acc { create(:account) }
    end

    trait :manual do
      vendor_invoice { false }
      start_date     { 7.days.ago.utc }
      end_date       { 1.day.ago.utc }
      type_id        { Billing::InvoiceType::MANUAL }
      account        { _acc }
      contractor     { _acc.contractor }
    end
  end
end
