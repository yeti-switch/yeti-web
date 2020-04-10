# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_states
#
#  id   :integer          not null, primary key
#  name :string           not null
#

FactoryGirl.define do
  factory :invoice_state, class: Billing::InvoiceState do
    id 1
    name 'Pending'

    trait :pending do
      id Billing::InvoiceState::PENDING
      name 'Pending'
    end

    trait :approved do
      id Billing::InvoiceState::APPROVED
      name 'Approved'
    end
  end
end
