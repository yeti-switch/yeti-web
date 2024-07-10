# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_accounts
#
#  id                             :bigint(8)        not null, primary key
#  autogenerate_customer_invoices :boolean          default(FALSE), not null
#  autogenerate_vendor_invoices   :boolean          default(FALSE), not null
#  balance                        :decimal(, )
#  contractor_name                :string
#  destination_rate_limit         :decimal(, )
#  error_string                   :string
#  invoice_period_name            :string
#  is_changed                     :boolean
#  max_balance                    :decimal(, )
#  max_call_duration              :integer(4)
#  min_balance                    :decimal(, )
#  name                           :string
#  origination_capacity           :integer(4)
#  termination_capacity           :integer(4)
#  total_capacity                 :integer(2)
#  vat                            :decimal(, )
#  contractor_id                  :integer(4)
#  invoice_period_id              :integer(2)
#  o_id                           :integer(4)
#
FactoryBot.define do
  factory :importing_account, class: Importing::Account do
    o_id { nil }
    name { nil }
    contractor_name { nil }
    contractor_id { nil }
    balance { 0 }
    vat { 18.2 }
    min_balance { 0 }
    max_balance { 0 }
    destination_rate_limit { 0.332 }
    max_call_duration { 18_000 }
    origination_capacity { 1 }
    termination_capacity { 1 }
    total_capacity { 3 }
    error_string { nil }
  end
end
