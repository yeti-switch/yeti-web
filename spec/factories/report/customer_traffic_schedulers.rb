# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.customer_traffic_report_schedulers
#
#  id          :integer(4)       not null, primary key
#  last_run_at :timestamptz
#  next_run_at :timestamptz
#  send_to     :integer(4)       is an Array
#  created_at  :timestamptz
#  customer_id :integer(4)       not null
#  period_id   :integer(4)       not null
#
# Foreign Keys
#
#  customer_traffic_report_schedulers_period_id_fkey  (period_id => scheduler_periods.id)
#

FactoryBot.define do
  factory :customer_traffic_scheduler, class: 'Report::CustomerTrafficScheduler' do
    period { Report::SchedulerPeriod.take || build(:period_scheduler) }
    association :customer
  end
end
