# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.scheduler_periods
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  scheduler_periods_name_key  (name) UNIQUE
#

FactoryBot.define do
  factory :period_scheduler, class: 'Report::SchedulerPeriod' do
    sequence(:id, &:n)
    sequence(:name) { |n| "Period Scheduler #{n}" }
  end
end
