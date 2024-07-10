# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.customer_traffic_report
#
#  id          :bigint(8)        not null, primary key
#  completed   :boolean          default(FALSE), not null
#  date_end    :timestamptz
#  date_start  :timestamptz
#  send_to     :integer(4)       is an Array
#  created_at  :timestamptz
#  customer_id :integer(4)       not null
#

FactoryBot.define do
  factory :customer_traffic, class: Report::CustomerTraffic do
    date_start { Time.now.utc }
    date_end { Time.now.utc + 1.week }

    association :customer, factory: :customer, customer: true
  end
end
