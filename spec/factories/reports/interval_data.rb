# frozen_string_literal: true

FactoryBot.define do
  factory :interval_data, class: Report::IntervalData do
    report { association :interval_cdr }
    destination_rate_policy_id { 1 }
  end
end
