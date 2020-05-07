# frozen_string_literal: true

FactoryGirl.define do
  factory :pop, class: Pop do
    sequence(:name) { |n| "Point of presence #{n}" }

    trait :filled do
      nodes { build_list :node, 2 }
      customer_auths { build_list :customers_auth, 2 }
      gateways { build_list :gateway, 2 }
    end
  end
end
