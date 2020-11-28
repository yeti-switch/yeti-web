# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_states
#
#  id   :integer          not null, primary key
#  name :string           not null
#

FactoryBot.define do
  factory :invoice_state, class: Billing::InvoiceState do
    trait :pending do
      id { Billing::InvoiceState::PENDING }
      # name { 'Pending' }
    end

    trait :approved do
      id { Billing::InvoiceState::APPROVED }
      # name { 'Approved' }
    end

    trait :new do
      id { Billing::InvoiceState::NEW }
      # name { 'Approved' }
    end
  end
end
