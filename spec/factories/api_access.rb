# frozen_string_literal: true

FactoryBot.define do
  factory :api_access, class: System::ApiAccess do
    sequence(:login) { |n| "api_access-#{n}" }
    password { ('a'..'z').to_a.shuffle.join }
    allowed_ips { ['0.0.0.0', '127.0.0.1'] }

    customer
  end
end
