# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_custom_report
#
#  id          :integer          not null, primary key
#  date_start  :datetime
#  date_end    :datetime
#  filter      :string
#  group_by    :string
#  created_at  :datetime
#  customer_id :integer
#

class Report::CustomCdr < Cdr::Base
  self.table_name = 'reports.cdr_custom_report'

  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id

  CDR_COLUMNS = %i[
    customer_id
    vendor_id
    rateplan_id
    routing_group_id
    orig_gw_id
    term_gw_id
    destination_id
    dialpeer_id
    customer_auth_id
    vendor_acc_id
    customer_acc_id
    disconnect_initiator_id
    vendor_invoice_id
    customer_invoice_id
    destination_rate_policy_id
    node_id
    pop_id
    destination_next_rate
    destination_fee
    dialpeer_next_rate
    dialpeer_fee
    time_limit
    customer_price
    vendor_price
    duration
    success
    vendor_billed
    customer_billed
    profit
    dst_prefix_in
    dst_prefix_out
    src_prefix_in
    src_prefix_out
    time_start
    time_connect
    time_end
    sign_orig_ip
    sign_orig_port
    sign_orig_local_ip
    sign_orig_local_port
    sign_term_ip
    sign_term_port
    sign_term_local_ip
    sign_term_local_port
    orig_call_id
    term_call_id
    local_tag
    log_sip
    log_rtp
    dump_file
    destination_initial_rate
    dialpeer_initial_rate
    destination_initial_interval
    destination_next_interval
    dialpeer_initial_interval
    dialpeer_next_interval
    routing_attempt
    is_last_cdr
    lega_disconnect_code
    lega_disconnect_reason
    legb_disconnect_code
    legb_disconnect_reason
    internal_disconnect_code
    internal_disconnect_reason
    src_name_in
    src_name_out
    diversion_in
    diversion_out
    dst_country_id
    dst_network_id
  ].freeze

  validates_presence_of :group_by_fields, :date_start, :date_end
  # validates do
  #   #TODO validation of GROUP BY input and filters input to prevent SQL injection
  #   group_by_fields.each do |x|
  #     CDR_COLUMNS.fetch(x)
  #   ends
  # end

  include GroupReportTools
  setup_report_with(Report::CustomData)

  after_create do
    # execute_sp("SELECT * FROM reports.cdr_custom_report(?)", self.id)
    execute_sp("INSERT INTO cdr_custom_report_data(
                  report_id,
                  #{group_by},
                  agg_calls_count,
                  agg_calls_duration,
                  agg_customer_price,
                  agg_vendor_price,
                  agg_profit,
                  agg_asr_origination,
                  agg_asr_termination,
                  agg_calls_acd
                )
                SELECT
                  ?,
                  #{group_by},
                  count(id),
                  sum(duration),
                  sum(customer_price),
                  sum(vendor_price),
                  sum(profit),
                  coalesce(count(nullif(success AND is_last_cdr,false))::float/nullif(count(nullif(is_last_cdr,false)),0)::float,0),
                  coalesce(count(nullif(success,false))::float/nullif(count(id),0)::float,0),
                  sum(duration)::float/nullif(count(nullif(success,false)),0)::float
                from cdr.cdr
                WHERE
                  time_start>=?
                  AND time_start<?
                  #{customer_sql_condition}
                  #{build_sql_filter}
                GROUP BY #{group_by}",
               id,
               date_start,
               date_end)
  end

  def build_sql_filter
    # TODO: REWRITE THIS SHIT
    if filter.empty?
      nil
    else
      "AND #{filter}"
    end
  end

  # TODO: REWRITE THIS SHIT
  def customer_sql_condition
    if customer_id.nil?
      nil
    else
      "AND customer_id = #{customer_id}"
    end
  end

  def display_name
    id.to_s
  end

  include Hints
  include CsvReport
  after_create do
    Reporter::CustomCdr.new(self).save!
  end
end
