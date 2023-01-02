# frozen_string_literal: true

FactoryBot.define do
  factory :interval_data, class: Report::IntervalData do
    report { association :interval_cdr }
    disconnect_initiator_id { 1 }
  end
end
