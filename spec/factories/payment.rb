FactoryGirl.define do
  factory :payment do
    amount 10
    association :account
    notes 'notes text'
  end
end
