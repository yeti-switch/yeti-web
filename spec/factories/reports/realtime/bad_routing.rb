# frozen_string_literal: true

FactoryGirl.define do
  factory :bad_routing, class: Report::Realtime::BadRouting do
    id 1
    time_start Time.zone.now.utc
    association customer_auth, factory: :customers_auth
  end
end
