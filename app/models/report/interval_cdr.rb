# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_interval_report
#
#  id              :integer(4)       not null, primary key
#  aggregate_by    :string           not null
#  completed       :boolean          default(FALSE), not null
#  date_end        :timestamptz      not null
#  date_start      :timestamptz      not null
#  filter          :string
#  group_by        :string           is an Array
#  interval_length :integer(4)       not null
#  send_to         :integer(4)       is an Array
#  created_at      :timestamptz      not null
#  aggregator_id   :integer(4)       not null
#
# Foreign Keys
#
#  cdr_interval_report_aggregator_id_fkey  (aggregator_id => cdr_interval_report_aggregator.id)
#

class Report::IntervalCdr < Cdr::Base
  self.table_name = 'reports.cdr_interval_report'

  # *NOTE* Creation from user input should be performed only through Report::IntervalCdrForm
  # *NOTE* Creation from business logic should be performed only through CreateReport::IntervalCdr

  INTERVALS = {
    5 => '5 Min',
    10 => '10 Min',
    30 => '30 Min',
    60 => '1 Hour',
    360 => '6 Hours',
    1440 => '1 Day'
  }.freeze

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
    auth_orig_ip
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

  CDR_COLUMNS_CONSTANTS = {
    disconnect_initiator_id: %i[disconnect_initiator disconnect_initiator_name].freeze,
    destination_rate_policy_id: %i[destination_rate_policy destination_rate_policy_name].freeze
  }.freeze

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

  validates :date_start, :date_end, :interval_length, :aggregation_function, :aggregate_by, presence: true

  include GroupReportTools
  setup_report_with(Report::IntervalData)

  def display_name
    id.to_s
  end

  def aggregation
    "#{aggregation_function.name}(#{aggregate_by})"
  end

  private

  def auto_column_constants
    CDR_COLUMNS_CONSTANTS
  end
end
