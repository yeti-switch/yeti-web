# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_custom_report_schedulers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  period_id   :integer          not null
#  filter      :string
#  group_by    :string           is an Array
#  send_to     :integer          is an Array
#  last_run_at :datetime
#  next_run_at :datetime
#  customer_id :integer
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
