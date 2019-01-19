# frozen_string_literal: true

FactoryGirl.define do
  factory :invoice_template, class: Billing::InvoiceTemplate do
    sequence(:name) { |n| "invoice_template#{n}" }
    filename 'filename.odt'
  end
end
