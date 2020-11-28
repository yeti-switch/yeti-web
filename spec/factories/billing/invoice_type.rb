# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_types
#
#  id   :integer          not null, primary key
#  name :string           not null
#

FactoryBot.define do
  factory :invoice_type, class: Billing::InvoiceType do
    uniq_name

    trait :manual do
      id { Billing::InvoiceType::MANUAL }
      # name { Billing::InvoiceType::NAMES[Billing::InvoiceType::MANUAL] }
    end

    trait :auto_full do
      id { Billing::InvoiceType::AUTO_FULL }
      # name { Billing::InvoiceType::NAMES[Billing::InvoiceType::AUTO_FULL] }
    end

    trait :auto_partial do
      id { Billing::InvoiceType::AUTO_PARTIAL }
      # name { Billing::InvoiceType::NAMES[Billing::InvoiceType::AUTO_PARTIAL] }
    end

    trait :uniq_name do
      sequence(:name) { |n| "Manual_#{n}" }
    end
  end
end
