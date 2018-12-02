FactoryGirl.define do
  factory :account, class: Account do
    sequence(:name) { |n| "account#{n}" }
    association :contractor, vendor: true
    balance 0
    vat 23.1
    destination_rate_limit 0.3444
    min_balance 0
    max_balance 0
    origination_capacity 1
    termination_capacity 2
    total_capacity 5
    timezone_id 1
  end
end
