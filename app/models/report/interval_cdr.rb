# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_interval_report
#
#  id              :integer          not null, primary key
#  date_start      :datetime         not null
#  date_end        :datetime         not null
#  filter          :string
#  group_by        :string
#  created_at      :datetime         not null
#  interval_length :integer          not null
#  aggregator_id   :integer          not null
#  aggregate_by    :string           not null
#

class Report::IntervalCdr < Cdr::Base
  self.table_name = 'reports.cdr_interval_report'

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
    local_tag
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

  CDR_AGG_COLUMNS = %i[
    destination_next_rate
    destination_fee
    dialpeer_next_rate
    dialpeer_fee
    time_limit
    customer_price
    vendor_price
    duration
    profit
    destination_initial_rate
    dialpeer_initial_rate
    destination_initial_interval
    destination_next_interval
    dialpeer_initial_interval
    dialpeer_next_interval
  ].freeze

  belongs_to :aggregation_function, class_name: 'Report::IntervalAggregator', foreign_key: :aggregator_id
  # has_many :data, class_name: 'Report::IntervalData', foreign_key: :report_id, dependent: :delete_all

  validates_presence_of :date_start, :date_end, :interval_length, :aggregation_function, :aggregate_by

  def display_name
    id.to_s
  end

  def aggregation
    "#{aggregation_function.name}(#{aggregate_by})"
  end

  include GroupReportTools
  setup_report_with(Report::IntervalData)

  after_create do
    execute_sp('SELECT * FROM reports.cdr_interval_report(?)', id)
  end

  include Hints
  include CsvReport
  after_create do
    Reporter::IntervalCdr.new(self).save!
  end
end
