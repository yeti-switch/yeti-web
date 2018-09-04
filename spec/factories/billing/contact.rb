FactoryGirl.define do
  factory :contact, class: Billing::Contact do
    sequence(:email) { |n| "rspec_mail_#{n}@example.com" }

    association :contractor, factory: :customer
  end
end
