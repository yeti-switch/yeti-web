# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.vendor_traffic_report_data
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
#  customer_id             :integer(4)
#  report_id               :integer(4)       not null
#
# Indexes
#
#  vendor_traffic_report_data_report_id_idx  (report_id)
#
# Foreign Keys
#
#  vendor_traffic_report_data_report_id_fkey  (report_id => vendor_traffic_report.id)
#

class Report::VendorTrafficData < Cdr::Base
  self.table_name = 'reports.vendor_traffic_report_data'

  belongs_to :report, class_name: 'Report::VendorTraffic', foreign_key: :report_id
  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id # ,:conditions => {:vendor => true}

  def display_name
    id.to_s
  end

  Totals = Struct.new(
    :calls_count, :success_calls_count, :short_calls_count,
    :calls_duration, :customer_calls_duration, :vendor_calls_duration,
    :origination_cost, :termination_cost,
    :profit, :first_call_at, :last_call_at
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
      'max(last_call_at) as last_call_at'
    )
    Totals.new(*row)
  end
end
