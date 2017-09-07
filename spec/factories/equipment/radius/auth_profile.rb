FactoryGirl.define do
  factory :auth_profile, class: Equipment::Radius::AuthProfile do
    sequence(:name) { |n| "auth_profile#{n}" }
    server 'server'
    port '1'
    secret 'secret'
    timeout 100
    attempts 2
  end
end
