# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.customer_traffic_report
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  date_start  :datetime
#  date_end    :datetime
#  customer_id :integer          not null
#

FactoryBot.define do
  factory :customer_traffic, class: Report::CustomerTraffic do
    date_start { Time.now.utc }
    date_end { Time.now.utc + 1.week }

    association :customer, factory: :customer, customer: true
  end
end
