# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_interval_report_schedulers
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  period_id       :integer          not null
#  filter          :string
#  group_by        :string           is an Array
#  interval_length :integer
#  aggregator_id   :integer
#  aggregate_by    :string
#  send_to         :integer          is an Array
#  last_run_at     :datetime
#  next_run_at     :datetime
#

FactoryGirl.define do
  factory :interval_cdr_scheduler, class: Report::IntervalCdrScheduler do
    period { Report::SchedulerPeriod.take || build(:period_scheduler) }
    group_by %w[customer_acc_id]
    interval_length 5
    aggregation_function { Report::IntervalAggregator.take }
    aggregate_by 'duration'
  end
end
