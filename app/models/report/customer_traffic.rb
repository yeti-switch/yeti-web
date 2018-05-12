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

class Report::CustomerTraffic < Cdr::Base
  self.table_name = 'reports.customer_traffic_report'

  has_many :customer_traffic_data_by_vendor, class_name: 'Report::CustomerTrafficDataByVendor', foreign_key: :report_id, dependent: :delete_all
  has_many :customer_traffic_data_by_destination, class_name: 'Report::CustomerTrafficDataByDestination', foreign_key: :report_id, dependent: :delete_all
  has_many :customer_traffic_data_full, class_name: 'Report::CustomerTrafficDataFull', foreign_key: :report_id, dependent: :delete_all

  belongs_to :customer, -> { where customer: true }, class_name: 'Contractor', foreign_key: :customer_id

  def report_records_by_vendor
    customer_traffic_data_by_vendor.includes(:vendor)
  end

  def report_records_by_destination
    #customer_traffic_data_by_destination.includes(:country, :network)
    customer_traffic_data_by_destination.report_records
  end

  def report_records_full
    customer_traffic_data_full.includes(:vendor, :country, :network)
  end

  validates_presence_of :date_start, :date_end, :customer_id

  GROUP_COLUMNS = [
      :vendor,
      :destination_prefix
  ]

  def display_name
    "#{self.id}"
  end

  after_create do
    execute_sp("INSERT INTO reports.customer_traffic_report_data_full(
                  report_id,
                  vendor_id, destination_prefix, dst_country_id, dst_network_id,
                  calls_count, short_calls_count,  success_calls_count,
                  calls_duration,
                  acd,
                  asr,
                  origination_cost ,termination_cost,
                  profit,
                  first_call_at, last_call_at
              )
              SELECT
                ?,
                vendor_id, destination_prefix, dst_country_id, dst_network_id,
                count(id), count(nullif((duration<=? AND success),false)), count(nullif(success,false)),
                sum(duration),
                sum(duration)::float/nullif(count(nullif(success,false)),0)::float, /* ACD */
                count(nullif(success,false))::float/nullif(count(id),0)::float,  /* ASR */
                sum(customer_price), sum(vendor_price),
                sum(profit),
                min(time_start), max(time_start)
              from cdr.cdr
              WHERE
                time_start>=?
                AND time_start<?
                AND customer_id=?
              GROUP BY vendor_id, destination_prefix, dst_country_id, dst_network_id",
               self.id,
               GuiConfig.short_call_length,
               self.date_start,
               self.date_end,
               self.customer_id
    )
    execute_sp("INSERT INTO reports.customer_traffic_report_data_by_vendor(
                  report_id,
                  vendor_id,
                  calls_count,  short_calls_count,  success_calls_count,
                  calls_duration,
                  acd,
                  asr,
                  origination_cost ,termination_cost,
                  profit,
                  first_call_at, last_call_at
              )
              SELECT
                ?,
                vendor_id,
                sum(calls_count), sum(short_calls_count), sum(success_calls_count),
                sum(calls_duration),
                sum(calls_duration)::float/sum(nullif(success_calls_count,0))::float,
                sum(success_calls_count)::float/sum(nullif(calls_count,0))::float,
                sum(origination_cost), sum(termination_cost),
                sum(profit),
                min(first_call_at), max(last_call_at)
              from reports.customer_traffic_report_data_full
              WHERE
                report_id=?
              GROUP BY vendor_id",
               self.id,
               self.id
    )

    execute_sp("INSERT INTO reports.customer_traffic_report_data_by_destination(
                  report_id,
                  destination_prefix, dst_country_id, dst_network_id,
                  calls_count,  short_calls_count,  success_calls_count,
                  calls_duration,
                  acd,
                  asr,
                  origination_cost ,termination_cost,
                  profit,
                  first_call_at, last_call_at
              )
              SELECT
                ?,
                destination_prefix, dst_country_id, dst_network_id,
                sum(calls_count), sum(short_calls_count), sum(success_calls_count),
                sum(calls_duration),
                sum(calls_duration)::float/sum(nullif(success_calls_count,0))::float,
                sum(success_calls_count)::float/sum(nullif(calls_count,0))::float,
                sum(origination_cost), sum(termination_cost),
                sum(profit),
                min(first_call_at), max(last_call_at)
              from reports.customer_traffic_report_data_full
              WHERE
                report_id=?
              GROUP BY destination_prefix, dst_country_id, dst_network_id",
               self.id,
               self.id
    )
  end

  include Hints
  include CsvReport
  after_create do
    Reporter::CustomerTraffic.new(self).save!
  end

  def csv_columns
    [:vendor,
     :calls_count,
     :success_calls_count,
     :short_calls_count,
     :calls_duration,
     :acd,
     :asr,
     :origination_cost,
     :termination_cost,
     :profit,
     :first_call_at,
     :last_call_at
    ]
  end

  def csv_columns_by_destination
    [
        :destination_prefix,
        :country,
        :network,
        :calls_count,
        :success_calls_count,
        :short_calls_count,
        :calls_duration,
        :acd,
        :asr,
        :origination_cost,
        :termination_cost,
        :profit,
        :first_call_at,
        :last_call_at
    ]
  end

  def csv_columns_full
    [
        :vendor,
        :destination_prefix,
        :country,
        :network,
        :calls_count,
        :success_calls_count,
        :short_calls_count,
        :calls_duration,
        :acd,
        :asr,
        :origination_cost,
        :termination_cost,
        :profit,
        :first_call_at,
        :last_call_at
    ]
  end


end
