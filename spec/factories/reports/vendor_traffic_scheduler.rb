# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.vendor_traffic_report_schedulers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  period_id   :integer          not null
#  vendor_id   :integer          not null
#  send_to     :integer          is an Array
#  last_run_at :datetime
#  next_run_at :datetime
#

FactoryGirl.define do
  factory :vendor_traffic_scheduler, class: Report::VendorTrafficScheduler do
    period { Report::SchedulerPeriod.take }
    vendor
  end
end
