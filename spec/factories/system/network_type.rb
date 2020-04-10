# frozen_string_literal: true

FactoryGirl.define do
  factory :network_type, class: System::NetworkType do
    sequence(:name) { |n| "Network type #{n}" }

    trait :filled do
      networks { build_list :network, 2 }
    end
  end
end
