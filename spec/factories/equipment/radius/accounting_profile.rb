FactoryGirl.define do
  factory :accounting_profile, class: Equipment::Radius::AccountingProfile do
    sequence(:name) { |n| "profile#{n}" }
    server 'server'
    port '1'
    secret 'secret'
    timeout 100
    attempts 2
  end
end
