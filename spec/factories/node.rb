# frozen_string_literal: true

FactoryBot.define do
  factory :node, class: Node do
    sequence(:name) { |n| "Node #{n}" }
    signalling_ip { '8.8.8.8' }
    signalling_port { 5061 }
    sequence(:rpc_endpoint) { |n| "127.0.0.1:#{1 + n}" }

    association :pop, factory: :pop

    trait :filled do
      registrations { build_list :registration, 2 }
    end
  end
end
