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
      country
      network
    end
  end
end
