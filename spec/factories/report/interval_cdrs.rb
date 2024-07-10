# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_interval_report
#
#  id              :integer(4)       not null, primary key
#  aggregate_by    :string           not null
#  completed       :boolean          default(FALSE), not null
#  date_end        :timestamptz      not null
#  date_start      :timestamptz      not null
#  filter          :string
#  group_by        :string           is an Array
#  interval_length :integer(4)       not null
#  send_to         :integer(4)       is an Array
#  created_at      :timestamptz      not null
#  aggregator_id   :integer(4)       not null
#
# Foreign Keys
#
#  cdr_interval_report_aggregator_id_fkey  (aggregator_id => cdr_interval_report_aggregator.id)
#

FactoryBot.define do
  factory :interval_cdr, class: Report::IntervalCdr do
    date_start { Time.now.utc }
    date_end { Time.now.utc + 1.week }
    interval_length { 10 }
    group_by { %w[disconnect_initiator_id] }
    aggregator_id { Report::IntervalAggregator.take.id }
    aggregate_by { 'destination_fee' }
  end
end
