# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.vendor_traffic_report_schedulers
#
#  id          :integer(4)       not null, primary key
#  last_run_at :timestamptz
#  next_run_at :timestamptz
#  send_to     :integer(4)       is an Array
#  created_at  :timestamptz
#  period_id   :integer(4)       not null
#  vendor_id   :integer(4)       not null
#
# Foreign Keys
#
#  vendor_traffic_report_schedulers_period_id_fkey  (period_id => scheduler_periods.id)
#

FactoryBot.define do
  factory :vendor_traffic_scheduler, class: 'Report::VendorTrafficScheduler' do
    period { Report::SchedulerPeriod.take }
    vendor
  end
end
