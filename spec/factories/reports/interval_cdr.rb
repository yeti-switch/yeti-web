# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_interval_report
#
#  id              :integer          not null, primary key
#  date_start      :datetime         not null
#  date_end        :datetime         not null
#  filter          :string
#  group_by        :string
#  created_at      :datetime         not null
#  interval_length :integer          not null
#  aggregator_id   :integer          not null
#  aggregate_by    :string           not null
#

FactoryBot.define do
  factory :interval_cdr, class: Report::IntervalCdr do
    date_start { Time.now.utc }
    date_end { Time.now.utc + 1.week }
    interval_length { 10 }
    group_by { 'destination_rate_policy_id' }
    aggregator_id { Report::IntervalAggregator.take.id }
    aggregate_by { 'destination_fee' }
  end
end
