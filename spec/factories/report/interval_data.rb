# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_interval_report_data
#
#  id                           :bigint(8)        not null, primary key
#  aggregated_value             :decimal(, )
#  auth_orig_ip                 :string
#  customer_price               :decimal(, )
#  destination_fee              :decimal(, )
#  destination_initial_interval :integer(4)
#  destination_initial_rate     :decimal(, )
#  destination_next_interval    :integer(4)
#  destination_next_rate        :decimal(, )
#  destination_reverse_billing  :boolean
#  dialpeer_fee                 :decimal(, )
#  dialpeer_initial_interval    :integer(4)
#  dialpeer_initial_rate        :decimal(, )
#  dialpeer_next_interval       :integer(4)
#  dialpeer_next_rate           :decimal(, )
#  dialpeer_reverse_billing     :boolean
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
#  time_connect                 :timestamptz
#  time_end                     :timestamptz
#  time_start                   :timestamptz
#  timestamp                    :timestamptz
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
# Indexes
#
#  cdr_interval_report_data_report_id_idx  (report_id)
#
# Foreign Keys
#
#  cdr_interval_report_data_report_id_fkey  (report_id => cdr_interval_report.id)
#
FactoryBot.define do
  factory :interval_data, class: 'Report::IntervalData' do
    report { association :interval_cdr }
    disconnect_initiator_id { 1 }
  end
end
