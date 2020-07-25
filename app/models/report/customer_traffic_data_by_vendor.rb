# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.customer_traffic_report_data_by_vendor
#
#  id                      :bigint(8)        not null, primary key
#  acd                     :float
#  asr                     :float
#  calls_count             :bigint(8)
#  calls_duration          :bigint(8)
#  customer_calls_duration :bigint(8)
#  first_call_at           :datetime
#  last_call_at            :datetime
#  origination_cost        :decimal(, )
#  profit                  :decimal(, )
#  short_calls_count       :bigint(8)
#  success_calls_count     :bigint(8)
#  termination_cost        :decimal(, )
#  vendor_calls_duration   :bigint(8)
#  report_id               :integer(4)       not null
#  vendor_id               :integer(4)
#
# Indexes
#
#  customer_traffic_report_data_report_id_idx  (report_id)
#
# Foreign Keys
#
#  customer_traffic_report_data_report_id_fkey  (report_id => customer_traffic_report.id)
#

class Report::CustomerTrafficDataByVendor < Cdr::Base
  self.table_name = 'reports.customer_traffic_report_data_by_vendor'

  belongs_to :report, class_name: 'Report::CustomerTraffic', foreign_key: :report_id
  belongs_to :vendor, class_name: 'Contractor', foreign_key: :vendor_id # ,:conditions => {:vendor => true}

  def display_name
    id.to_s
  end

  Totals = Struct.new(
    :calls_count, :success_calls_count, :short_calls_count,
    :calls_duration, :customer_calls_duration, :vendor_calls_duration,
    :origination_cost, :termination_cost, :profit,
    :first_call_at, :last_call_at, :agg_acd
  )

  def self.totals
    row = extending(ActsAsTotalsRelation).totals_row_by(
      'sum(calls_count)::int as calls_count',
      'sum(success_calls_count)::int as success_calls_count',
      'sum(short_calls_count)::int as short_calls_count',
      'sum(calls_duration) as calls_duration',
      'sum(customer_calls_duration) as customer_calls_duration',
      'sum(vendor_calls_duration) as vendor_calls_duration',
      'sum(origination_cost) as origination_cost',
      'sum(termination_cost) as termination_cost',
      'sum(profit) as profit',
      'min(first_call_at) as first_call_at',
      'max(last_call_at) as last_call_at',
      'coalesce(sum(calls_duration)::float/nullif(sum(success_calls_count),0),0) as agg_acd'
    )
    Totals.new(*row)
  end
end
