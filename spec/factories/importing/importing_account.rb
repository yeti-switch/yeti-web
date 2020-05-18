# frozen_string_literal: true

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
