# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.customer_traffic_report_data_by_vendor
#
#  id                  :integer          not null, primary key
#  report_id           :integer          not null
#  vendor_id           :integer
#  calls_count         :integer
#  calls_duration      :integer
#  acd                 :float
#  asr                 :float
#  origination_cost    :decimal(, )
#  termination_cost    :decimal(, )
#  profit              :decimal(, )
#  success_calls_count :integer
#  first_call_at       :datetime
#  last_call_at        :datetime
#  short_calls_count   :integer
#

class Report::CustomerTrafficDataByVendor < Cdr::Base
  self.table_name = 'reports.customer_traffic_report_data_by_vendor'

  belongs_to :report, class_name: 'Report::CustomerTraffic', foreign_key: :report_id
  belongs_to :vendor, class_name: 'Contractor', foreign_key: :vendor_id # ,:conditions => {:vendor => true}

  def display_name
    id.to_s
  end

  def self.totals
    select("sum(calls_count)::int as calls_count,
            sum(success_calls_count)::int as success_calls_count,
            sum(short_calls_count)::int as short_calls_count,
            sum(calls_duration) as calls_duration,
            sum(origination_cost) as origination_cost,
            sum(termination_cost) as termination_cost,
            sum(profit) as profit,
            min(first_call_at) as first_call_at,
            max(last_call_at) as last_call_at,
            coalesce(sum(calls_duration)::float/nullif(sum(success_calls_count),0),0) as agg_acd").take
  end
end
