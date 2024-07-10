# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_custom_report_data
#
#  id                           :bigint(8)        not null, primary key
#  agg_asr_origination          :decimal(, )
#  agg_asr_termination          :decimal(, )
#  agg_calls_acd                :decimal(, )
#  agg_calls_count              :bigint(8)
#  agg_calls_duration           :bigint(8)
#  agg_customer_calls_duration  :bigint(8)
#  agg_customer_price           :decimal(, )
#  agg_customer_price_no_vat    :decimal(, )
#  agg_profit                   :decimal(, )
#  agg_short_calls_count        :bigint(8)
#  agg_successful_calls_count   :bigint(8)
#  agg_uniq_calls_count         :bigint(8)
#  agg_vendor_calls_duration    :bigint(8)
#  agg_vendor_price             :decimal(, )
#  auth_orig_ip                 :string
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
#  duration                     :integer(4)
#  internal_disconnect_code     :integer(4)
#  internal_disconnect_reason   :string
#  is_last_cdr                  :boolean
#  lega_disconnect_code         :integer(4)
#  lega_disconnect_reason       :string
#  lega_user_agent              :string
#  legb_disconnect_code         :integer(4)
#  legb_disconnect_reason       :string
#  legb_user_agent              :string
#  p_charge_info_in             :string
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
#  customer_acc_id              :integer(4)
#  customer_auth_id             :integer(4)
#  customer_id                  :integer(4)
#  customer_invoice_id          :integer(4)
#  destination_id               :integer(4)
#  destination_rate_policy_id   :integer(4)
#  dialpeer_id                  :integer(4)
#  disconnect_initiator_id      :integer(4)
#  dst_area_id                  :integer(4)
#  dst_country_id               :integer(4)
#  dst_network_id               :integer(4)
#  node_id                      :integer(4)
#  orig_gw_id                   :integer(4)
#  pop_id                       :integer(4)
#  rateplan_id                  :integer(4)
#  report_id                    :integer(4)       not null
#  routing_group_id             :integer(4)
#  src_area_id                  :integer(4)
#  src_country_id               :integer(4)
#  src_network_id               :integer(4)
#  term_gw_id                   :integer(4)
#  vendor_acc_id                :integer(4)
#  vendor_id                    :integer(4)
#  vendor_invoice_id            :integer(4)
#
# Indexes
#
#  cdr_custom_report_data_report_id_idx  (report_id)
#
# Foreign Keys
#
#  cdr_custom_report_data_report_id_fkey  (report_id => cdr_custom_report.id)
#
FactoryBot.define do
  factory :custom_data, class: Report::CustomData do
    report { association :interval_cdr }
  end
end
