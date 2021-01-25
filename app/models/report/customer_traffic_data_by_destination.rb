# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.customer_traffic_report_data_by_destination
#
#  id                      :bigint(8)        not null, primary key
#  acd                     :float
#  asr                     :float
#  calls_count             :bigint(8)        not null
#  calls_duration          :bigint(8)        not null
#  customer_calls_duration :bigint(8)        not null
#  destination_prefix      :string
#  first_call_at           :datetime
#  last_call_at            :datetime
#  origination_cost        :decimal(, )
#  profit                  :decimal(, )
#  short_calls_count       :bigint(8)        not null
#  success_calls_count     :bigint(8)
#  termination_cost        :decimal(, )
#  vendor_calls_duration   :bigint(8)        not null
#  dst_country_id          :integer(4)
#  dst_network_id          :integer(4)
#  report_id               :integer(4)       not null
#

class Report::CustomerTrafficDataByDestination < Cdr::Base
  self.table_name = 'reports.customer_traffic_report_data_by_destination'

  belongs_to :report, class_name: 'Report::CustomerTraffic', foreign_key: :report_id
  belongs_to :country, class_name: 'System::Country', foreign_key: :dst_country_id, optional: true
  belongs_to :network, class_name: 'System::Network', foreign_key: :dst_network_id, optional: true

  def display_name
    id.to_s
  end

  Totals = Struct.new(
    :calls_count, :success_calls_count, :short_calls_count,
    :calls_duration, :customer_calls_duration, :vendor_calls_duration,
    :origination_cost,
    :termination_cost, :profit, :first_call_at, :last_call_at, :agg_acd
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

  def self.report_records
    preload(:country, :network)
  end

  def self.csv_columns
    %i[
      destination_prefix
      country
      network
      calls_count
      calls_duration
      customer_calls_duration
      vendor_calls_duration
      acd
      asr
      origination_cost
      termination_cost
      profit
      success_calls_count
      first_call_at
      last_call_at
      short_calls_count
    ]
  end
end
