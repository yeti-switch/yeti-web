# frozen_string_literal: true

FactoryBot.define do
  factory :disconnect_initiator, class: DisconnectInitiator do
    sequence(:id) { |n| n }
    name { 'Disconnect initiator' }

    trait :traffic_manager do
      id { DisconnectInitiator::ID_TRAFFIC_MANAGER }
      name { 'Traffic manager' }
    end

    trait :traffic_switch do
      id { DisconnectInitiator::ID_TRAFFIC_SWITCH }
      name { 'Traffic switch' }
    end

    trait :destination do
      id { DisconnectInitiator::ID_DESTINATION }
      name { 'Destination' }
    end

    trait :origination do
      id { DisconnectInitiator::ID_ORIGINATION }
      name { 'Origination' }
    end
  end
end
