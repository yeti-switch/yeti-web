# frozen_string_literal: true

FactoryBot.define do
  factory :network_type, class: System::NetworkType do
    sequence(:name) { |n| "Network type #{n}" }
    uuid { SecureRandom.uuid }

    trait :filled do
      networks { System::Network.take(2) }
    end
  end
end
