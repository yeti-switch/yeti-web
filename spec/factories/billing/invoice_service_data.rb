# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_service_data
#
#  id                 :bigint(8)        not null, primary key
#  amount             :decimal(, )      not null
#  spent              :boolean          default(TRUE), not null
#  transactions_count :integer(4)       not null
#  invoice_id         :integer(4)       not null
#  service_id         :bigint(8)
#
# Indexes
#
#  invoice_service_data_invoice_id_idx  (invoice_id)
#
# Foreign Keys
#
#  invoice_service_data_invoice_id_fkey  (invoice_id => invoices.id)
#
FactoryBot.define do
  factory :invoice_service_data, class: 'Billing::InvoiceServiceData' do
    invoice { FactoryBot.create(:invoice, :manual, account: FactoryBot.create(:account)) }
    transactions_count { 1 }
    amount { 0.01 }
    spent { true }

    trait :filled do
      service { FactoryBot.create(:service, account: invoice.account) }
      transactions_count { rand(1..100) }
      amount { (transactions_count * rand(5)).round(6) }
      spent { [true, false].sample }
    end
  end
end
