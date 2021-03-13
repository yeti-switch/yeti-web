# frozen_string_literal: true

FactoryBot.define do
  factory :registration, class: Equipment::Registration do
    sequence(:name) { |n| "Equipment Registration #{n}" }
    domain { 'localhost' }
    username { 'user name' }
    contact { 'sip:user@domain' }

    trait :filled do
      node
      pop
      transport_protocol { Equipment::TransportProtocol.take }
      sip_schema { System::SipSchema.take }
      proxy_transport_protocol { Equipment::TransportProtocol.take }
      sequence(:sip_interface_name) { |n| "interface_#{n}" }
    end
  end
end
