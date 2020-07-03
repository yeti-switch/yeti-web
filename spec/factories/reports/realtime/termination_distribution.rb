# frozen_string_literal: true

FactoryBot.define do
  factory :realtime_termination_distribution, class: Report::Realtime::TerminationDistribution do
    time_start { Time.now.utc }
    uuid { SecureRandom.uuid }
  end
end
