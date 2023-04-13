# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_destinations
#
#  id                       :integer          not null, primary key
#  dst_prefix               :string
#  country_id               :integer
#  network_id               :integer
#  rate                     :decimal(, )
#  calls_count              :integer
#  calls_duration           :integer
#  amount                   :decimal(, )
#  invoice_id               :integer          not null
#  first_call_at            :datetime
#  last_call_at             :datetime
#  successful_calls_count   :integer
#  first_successful_call_at :datetime
#  last_successful_call_at  :datetime
#  billing_duration         :integer
#

FactoryBot.define do
  factory :invoice_destination, class: Billing::InvoiceDestination do
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
      first_successful_call_at { 24.hours.ago }
      last_successful_call_at { 1.minute.ago }
      last_call_at { 1.second.ago }
    end
  end
end
