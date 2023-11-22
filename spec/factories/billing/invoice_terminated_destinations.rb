# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_terminated_destinations
#
#  id                     :bigint(8)        not null, primary key
#  amount                 :decimal(, )
#  billing_duration       :bigint(8)
#  calls_count            :bigint(8)
#  calls_duration         :bigint(8)
#  dst_prefix             :string
#  first_call_at          :timestamptz
#  last_call_at           :timestamptz
#  rate                   :decimal(, )
#  successful_calls_count :bigint(8)
#  country_id             :integer(4)
#  invoice_id             :integer(4)       not null
#  network_id             :integer(4)
#
# Indexes
#
#  invoice_terminated_destinations_invoice_id_idx  (invoice_id)
#
# Foreign Keys
#
#  invoice_terminated_destinations_invoice_id_fkey  (invoice_id => invoices.id)
#

FactoryBot.define do
  factory :invoice_terminated_destination, class: Billing::InvoiceTerminatedDestination do
    invoice

    trait :filled do
      country { FactoryBot.create(:country, :uniq_name) }
      network { FactoryBot.create(:network, :uniq_name) }
    end

    trait :success do
      filled
      sequence(:dst_prefix, &:to_s)
      rate { rand + rand(5) }
      successful_calls_count { rand(1..1000) }
      calls_duration { successful_calls_count + (successful_calls_count * rand(100)) }
      amount { (successful_calls_count * rand(5)).round(6) }
      first_call_at { 25.hours.ago }
      last_call_at { 1.second.ago }
    end
  end
end
