# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_custom_report
#
#  id          :integer(4)       not null, primary key
#  completed   :boolean          default(FALSE), not null
#  date_end    :datetime
#  date_start  :datetime
#  filter      :string
#  group_by    :string           is an Array
#  send_to     :integer(4)       is an Array
#  created_at  :datetime
#  customer_id :integer(4)
#
# Indexes
#
#  cdr_custom_report_id_idx  (id) UNIQUE WHERE (id IS NOT NULL)
#

class Report::CustomCdr < Cdr::Base
  self.table_name = 'reports.cdr_custom_report'

  # *NOTE* Creation from user input should be performed only through Report::CustomCdrForm
  # *NOTE* Creation from business logic should be performed only through CreateReport::CustomCdr

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
    src_area_id
    dst_area_id
    src_network_id
    src_country_id
    lega_user_agent
    legb_user_agent
    p_charge_info_in
  ].freeze

  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id, optional: true

  validates :group_by, :date_start, :date_end, presence: true

  include GroupReportTools
  setup_report_with(Report::CustomData)

  def display_name
    id.to_s
  end
end
