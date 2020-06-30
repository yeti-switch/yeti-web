# frozen_string_literal: true

FactoryBot.define do
  factory :disconnect_initiator, class: DisconnectInitiator do
    id { 0 }
    name { 'initiator' }
  end
end
