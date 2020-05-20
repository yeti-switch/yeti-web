# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.scheduler_periods
#
#  id   :integer          not null, primary key
#  name :string           not null
#

FactoryBot.define do
  factory :period_scheduler, class: Report::SchedulerPeriod do
    sequence(:id, &:n)
    sequence(:name) { |n| "Period Scheduler #{n}" }
  end
end
