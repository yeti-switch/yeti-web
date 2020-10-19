# frozen_string_literal: true

FactoryBot.define do
  factory :node, class: Node do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "Node #{n}" }
    sequence(:rpc_endpoint) { |n| "127.0.0.1:#{1 + n}" }

    association :pop, factory: :pop

    trait :filled do
      registrations { build_list :registration, 2 }
    end
  end
end
