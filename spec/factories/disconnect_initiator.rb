# frozen_string_literal: true

FactoryBot.define do
  factory :disconnect_initiator, class: DisconnectInitiator do
    sequence(:id) { |n| n }
    name { 'Disconnect initiator' }

    trait :traffic_manager do
      id { 0 }
      name { 'Traffic manager' }
    end

    trait :traffic_switch do
      id { 1 }
      name { 'Traffic switch' }
    end

    trait :destination do
      id { 2 }
      name { 'Destination' }
    end

    trait :Origination do
      id { 3 }
      name { 'Origination' }
    end
  end
end
