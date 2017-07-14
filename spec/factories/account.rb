FactoryGirl.define do
  factory :account, class: Account do
    sequence(:name) { |n| "account#{n}" }
    association :contractor, vendor: true
    balance 0
    min_balance 0
    max_balance 0
    origination_capacity 1
    termination_capacity 2
    timezone_id 1
  end
end
