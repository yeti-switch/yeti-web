FactoryGirl.define do
  factory :registration, class: Equipment::Registration do
    sequence(:name) { |n| "Equipment Registration #{n}" }
    domain 'localhost'
    username 'user name'
    contact 'sip:user@domain'
  end
end
