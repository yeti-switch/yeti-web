# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.customer_traffic_report_schedulers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  period_id   :integer          not null
#  customer_id :integer          not null
#  last_run_at :datetime
#  next_run_at :datetime
#  send_to     :integer          is an Array
#

FactoryGirl.define do
  factory :customer_traffic_scheduler, class: Report::CustomerTrafficScheduler do
    period { Report::SchedulerPeriod.take || build(:period_scheduler) }
    association :customer
  end
end
