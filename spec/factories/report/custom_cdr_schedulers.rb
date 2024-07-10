# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_custom_report_schedulers
#
#  id          :integer(4)       not null, primary key
#  filter      :string
#  group_by    :string           is an Array
#  last_run_at :timestamptz
#  next_run_at :timestamptz
#  send_to     :integer(4)       is an Array
#  created_at  :timestamptz
#  customer_id :integer(4)
#  period_id   :integer(4)       not null
#
# Foreign Keys
#
#  cdr_custom_report_schedulers_period_id_fkey  (period_id => scheduler_periods.id)
#

FactoryBot.define do
  factory :custom_cdr_scheduler, class: Report::CustomCdrScheduler do
    period { Report::SchedulerPeriod.take || build(:period_scheduler) }
    group_by { %w[customer_id rateplan_id] }

    trait :filled do
      customer
    end
  end
end
