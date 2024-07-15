# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_originated_networks
#
#  id                     :bigint(8)        not null, primary key
#  amount                 :decimal(, )
#  billing_duration       :bigint(8)
#  calls_count            :bigint(8)
#  calls_duration         :bigint(8)
#  first_call_at          :timestamptz
#  last_call_at           :timestamptz
#  rate                   :decimal(, )
#  spent                  :boolean          default(TRUE), not null
#  successful_calls_count :bigint(8)
#  country_id             :integer(4)
#  invoice_id             :integer(4)       not null
#  network_id             :integer(4)
#
# Indexes
#
#  invoice_originated_networks_invoice_id_idx  (invoice_id)
#
# Foreign Keys
#
#  invoice_originated_networks_invoice_id_fkey  (invoice_id => invoices.id)
#

FactoryBot.define do
  factory :invoice_originated_network, class: 'Billing::InvoiceOriginatedNetwork' do
    invoice { FactoryBot.create(:invoice, :manual, account: FactoryBot.create(:account)) }

    trait :filled do
      country { FactoryBot.create(:country, :uniq_name) }
      network { FactoryBot.create(:network, :uniq_name) }
    end

    trait :success do
      filled
      rate { rand + rand(5) }
      successful_calls_count { rand(1..1000) }
      calls_duration { successful_calls_count + (successful_calls_count * rand(100)) }
      amount { (successful_calls_count * rand(5)).round(6) }
      first_call_at { 25.hours.ago }
      last_call_at { 1.second.ago }
    end
  end
end
