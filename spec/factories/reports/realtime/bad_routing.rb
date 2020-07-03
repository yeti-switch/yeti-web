# frozen_string_literal: true

FactoryBot.define do
  factory :bad_routing, class: Report::Realtime::BadRouting do
    time_start { 60.seconds.ago.utc } # this record will be showed during 60 second
    disconnect_initiator { DisconnectInitiator.find_by(id: 0) || create(:disconnect_initiator, :traffic_manager) }
    customer_auth { create :customers_auth }
    uuid { SecureRandom.uuid }
  end
end
