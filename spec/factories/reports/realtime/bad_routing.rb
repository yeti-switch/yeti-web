# frozen_string_literal: true

FactoryBot.define do
  factory :bad_routing, class: Report::Realtime::BadRouting, parent: :cdr do
    time_start { 110.seconds.ago } # this record will be available in page during 10 second
    disconnect_initiator { DisconnectInitiator.find_by(id: 0) || create(:disconnect_initiator, :traffic_manager) }
    association :customer_auth, factory: :customers_auth
  end
end
