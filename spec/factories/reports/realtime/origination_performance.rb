# frozen_string_literal: true

FactoryBot.define do
  factory :realtime_origination_performance, class: Report::Realtime::OriginationPerformance do
    time_start { Time.now.utc }
    uuid { SecureRandom.uuid }
  end
end
