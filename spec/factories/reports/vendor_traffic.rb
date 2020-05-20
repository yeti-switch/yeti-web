# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.vendor_traffic_report
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  date_start :datetime
#  date_end   :datetime
#  vendor_id  :integer          not null
#

FactoryBot.define do
  factory :vendor_traffic, class: Report::VendorTraffic do
    date_start { Time.now.utc }
    date_end { Time.now.utc + 1.week }
    association :vendor
  end
end
