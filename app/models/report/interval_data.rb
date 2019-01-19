# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_interval_report_data
#
#  customer_id                  :integer
#  vendor_id                    :integer
#  customer_acc_id              :integer
#  vendor_acc_id                :integer
#  customer_auth_id             :integer
#  destination_id               :integer
#  dialpeer_id                  :integer
#  orig_gw_id                   :integer
#  term_gw_id                   :integer
#  routing_group_id             :integer
#  rateplan_id                  :integer
#  destination_next_rate        :decimal(, )
#  destination_fee              :decimal(, )
#  dialpeer_next_rate           :decimal(, )
#  dialpeer_fee                 :decimal(, )
#  time_limit                   :string
#  internal_disconnect_code     :integer
#  internal_disconnect_reason   :string
#  disconnect_initiator_id      :integer
#  customer_price               :decimal(, )
#  vendor_price                 :decimal(, )
#  duration                     :integer
#  success                      :boolean
#  vendor_billed                :boolean
#  customer_billed              :boolean
#  profit                       :decimal(, )
#  dst_prefix_in                :string
#  dst_prefix_out               :string
#  src_prefix_in                :string
#  src_prefix_out               :string
#  time_start                   :datetime
#  time_connect                 :datetime
#  time_end                     :datetime
#  sign_orig_ip                 :string
#  sign_orig_port               :integer
#  sign_orig_local_ip           :string
#  sign_orig_local_port         :integer
#  sign_term_ip                 :string
#  sign_term_port               :integer
#  sign_term_local_ip           :string
#  sign_term_local_port         :integer
#  orig_call_id                 :string
#  term_call_id                 :string
#  vendor_invoice_id            :integer
#  customer_invoice_id          :integer
#  local_tag                    :string
#  log_sip                      :boolean
#  log_rtp                      :boolean
#  dump_file                    :string
#  destination_initial_rate     :decimal(, )
#  dialpeer_initial_rate        :decimal(, )
#  destination_initial_interval :integer
#  destination_next_interval    :integer
#  dialpeer_initial_interval    :integer
#  dialpeer_next_interval       :integer
#  destination_rate_policy_id   :integer
#  routing_attempt              :integer
#  is_last_cdr                  :boolean
#  lega_disconnect_code         :integer
#  lega_disconnect_reason       :string
#  pop_id                       :integer
#  node_id                      :integer
#  src_name_in                  :string
#  src_name_out                 :string
#  diversion_in                 :string
#  diversion_out                :string
#  dst_country_id               :integer
#  dst_network_id               :integer
#  legb_disconnect_code         :integer
#  legb_disconnect_reason       :string
#  id                           :integer          not null, primary key
#  report_id                    :integer          not null
#  timestamp                    :datetime
#  aggregated_value             :decimal(, )
#

class Report::IntervalData < Cdr::Base
  self.table_name = 'reports.cdr_interval_report_data'

  belongs_to :report, class_name: 'Report::IntervalCdr', foreign_key: :report_id

  belongs_to :rateplan
  belongs_to :routing_group
  belongs_to :orig_gw, class_name: 'Gateway', foreign_key: :orig_gw_id
  belongs_to :term_gw, class_name: 'Gateway', foreign_key: :term_gw_id
  belongs_to :destination, class_name: 'Routing::Destination'
  belongs_to :dialpeer
  belongs_to :customer_auth, class_name: 'CustomersAuth', foreign_key: :customer_auth_id
  belongs_to :vendor_acc, class_name: 'Account', foreign_key: :vendor_acc_id
  belongs_to :customer_acc, class_name: 'Account', foreign_key: :customer_acc_id
  belongs_to :vendor, class_name: 'Contractor', foreign_key: :vendor_id # , :conditions => {:vendor => true}
  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id # ,  :conditions => {:customer => true}
  belongs_to :disconnect_initiator
  belongs_to :vendor_invoice, class_name: 'Invoice', foreign_key: :vendor_invoice_id
  belongs_to :customer_invoice, class_name: 'Invoice', foreign_key: :customer_invoice_id
  belongs_to :destination_rate_policy, class_name: 'DestinationRatePolicy', foreign_key: :destination_rate_policy_id
  belongs_to :node, class_name: 'Node', foreign_key: :node_id
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id
  belongs_to :dst_country, class_name: 'System::Country', foreign_key: :dst_country_id
  belongs_to :dst_network, class_name: 'System::Network', foreign_key: :dst_network_id

  def self.report_columns
    %i[timestamp aggregated_value]
  end

  def display_name
    id.to_s
  end
end
