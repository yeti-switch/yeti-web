FactoryGirl.define do
  factory :account, class: Account do
    name nil
    contractor_id nil
    balance 0
    min_balance 0
    max_balance 0
    origination_capacity 0
    termination_capacity 0
  end
end
