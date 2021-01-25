# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_interval_report_data
#
#  id                           :bigint(8)        not null, primary key
#  aggregated_value             :decimal(, )
#  customer_billed              :boolean
#  customer_price               :decimal(, )
#  destination_fee              :decimal(, )
#  destination_initial_interval :integer(4)
#  destination_initial_rate     :decimal(, )
#  destination_next_interval    :integer(4)
#  destination_next_rate        :decimal(, )
#  dialpeer_fee                 :decimal(, )
#  dialpeer_initial_interval    :integer(4)
#  dialpeer_initial_rate        :decimal(, )
#  dialpeer_next_interval       :integer(4)
#  dialpeer_next_rate           :decimal(, )
#  diversion_in                 :string
#  diversion_out                :string
#  dst_prefix_in                :string
#  dst_prefix_out               :string
#  dump_file                    :string
#  duration                     :integer(4)
#  internal_disconnect_code     :integer(4)
#  internal_disconnect_reason   :string
#  is_last_cdr                  :boolean
#  lega_disconnect_code         :integer(4)
#  lega_disconnect_reason       :string
#  legb_disconnect_code         :integer(4)
#  legb_disconnect_reason       :string
#  local_tag                    :string
#  log_rtp                      :boolean
#  log_sip                      :boolean
#  profit                       :decimal(, )
#  routing_attempt              :integer(4)
#  sign_orig_ip                 :string
#  sign_orig_local_ip           :string
#  sign_orig_local_port         :integer(4)
#  sign_orig_port               :integer(4)
#  sign_term_ip                 :string
#  sign_term_local_ip           :string
#  sign_term_local_port         :integer(4)
#  sign_term_port               :integer(4)
#  src_name_in                  :string
#  src_name_out                 :string
#  src_prefix_in                :string
#  src_prefix_out               :string
#  success                      :boolean
#  time_connect                 :datetime
#  time_end                     :datetime
#  time_limit                   :string
#  time_start                   :datetime
#  timestamp                    :datetime
#  vendor_billed                :boolean
#  vendor_price                 :decimal(, )
#  customer_acc_id              :integer(4)
#  customer_auth_id             :integer(4)
#  customer_id                  :integer(4)
#  customer_invoice_id          :integer(4)
#  destination_id               :integer(4)
#  destination_rate_policy_id   :integer(4)
#  dialpeer_id                  :integer(4)
#  disconnect_initiator_id      :integer(4)
#  dst_country_id               :integer(4)
#  dst_network_id               :integer(4)
#  node_id                      :integer(4)
#  orig_call_id                 :string
#  orig_gw_id                   :integer(4)
#  pop_id                       :integer(4)
#  rateplan_id                  :integer(4)
#  report_id                    :integer(4)       not null
#  routing_group_id             :integer(4)
#  term_call_id                 :string
#  term_gw_id                   :integer(4)
#  vendor_acc_id                :integer(4)
#  vendor_id                    :integer(4)
#  vendor_invoice_id            :integer(4)
#
# Foreign Keys
#
#  cdr_interval_report_data_report_id_fkey  (report_id => cdr_interval_report.id)
#

class Report::IntervalData < Cdr::Base
  self.table_name = 'reports.cdr_interval_report_data'

  belongs_to :report, class_name: 'Report::IntervalCdr', foreign_key: :report_id

  belongs_to :rateplan, optional: true
  belongs_to :routing_group, optional: true
  belongs_to :orig_gw, class_name: 'Gateway', foreign_key: :orig_gw_id, optional: true
  belongs_to :term_gw, class_name: 'Gateway', foreign_key: :term_gw_id, optional: true
  belongs_to :destination, class_name: 'Routing::Destination', optional: true
  belongs_to :dialpeer, optional: true
  belongs_to :customer_auth, class_name: 'CustomersAuth', foreign_key: :customer_auth_id, optional: true
  belongs_to :vendor_acc, class_name: 'Account', foreign_key: :vendor_acc_id, optional: true
  belongs_to :customer_acc, class_name: 'Account', foreign_key: :customer_acc_id, optional: true
  belongs_to :vendor, class_name: 'Contractor', foreign_key: :vendor_id, optional: true # , :conditions => {:vendor => true}
  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id, optional: true # ,  :conditions => {:customer => true}
  belongs_to :disconnect_initiator, optional: true
  belongs_to :vendor_invoice, class_name: 'Invoice', foreign_key: :vendor_invoice_id, optional: true
  belongs_to :customer_invoice, class_name: 'Invoice', foreign_key: :customer_invoice_id, optional: true
  belongs_to :destination_rate_policy, class_name: 'DestinationRatePolicy', foreign_key: :destination_rate_policy_id, optional: true
  belongs_to :node, class_name: 'Node', foreign_key: :node_id, optional: true
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id, optional: true
  belongs_to :dst_country, class_name: 'System::Country', foreign_key: :dst_country_id, optional: true
  belongs_to :dst_network, class_name: 'System::Network', foreign_key: :dst_network_id, optional: true

  def self.report_columns
    %i[timestamp aggregated_value]
  end

  def display_name
    id.to_s
  end
end
