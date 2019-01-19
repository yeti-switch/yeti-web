# frozen_string_literal: true

FactoryGirl.define do
  factory :smtp_connection, class: System::SmtpConnection do
    sequence(:name) { |n| "smtp_connection#{n}" }
    host 'host'
    port '25'
    from_address 'address@email.com'
    global true
  end
end
