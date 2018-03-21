FactoryGirl.define do
  factory :importing_account, class: Importing::Account do
    o_id nil
    name nil
    contractor_name nil
    contractor_id nil
    balance 0
    min_balance 0
    max_balance 0
    origination_capacity 1
    termination_capacity 1
    error_string nil
  end
end
