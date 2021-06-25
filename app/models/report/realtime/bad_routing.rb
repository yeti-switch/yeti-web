# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr.cdr
#
#  id                              :bigint(8)        not null
#  audio_recorded                  :boolean
#  auth_orig_ip                    :inet
#  auth_orig_port                  :integer(4)
#  core_version                    :string
#  customer_acc_vat                :decimal(, )
#  customer_account_check_balance  :boolean
#  customer_auth_name              :string
#  customer_duration               :integer(4)
#  customer_price                  :decimal(, )
#  customer_price_no_vat           :decimal(, )
#  destination_fee                 :decimal(, )
#  destination_initial_interval    :integer(4)
#  destination_initial_rate        :decimal(, )
#  destination_next_interval       :integer(4)
#  destination_next_rate           :decimal(, )
#  destination_prefix              :string
#  destination_reverse_billing     :boolean
#  dialpeer_fee                    :decimal(, )
#  dialpeer_initial_interval       :integer(4)
#  dialpeer_initial_rate           :decimal(, )
#  dialpeer_next_interval          :integer(4)
#  dialpeer_next_rate              :decimal(, )
#  dialpeer_prefix                 :string
#  dialpeer_reverse_billing        :boolean
#  diversion_in                    :string
#  diversion_out                   :string
#  dst_prefix_in                   :string
#  dst_prefix_out                  :string
#  dst_prefix_routing              :string
#  duration                        :integer(4)
#  early_media_present             :boolean
#  from_domain                     :string
#  global_tag                      :string
#  internal_disconnect_code        :integer(4)
#  internal_disconnect_reason      :string
#  is_last_cdr                     :boolean
#  is_redirected                   :boolean
#  lega_disconnect_code            :integer(4)
#  lega_disconnect_reason          :string
#  lega_identity                   :jsonb
#  lega_rx_bytes                   :integer(4)
#  lega_rx_decode_errs             :integer(4)
#  lega_rx_no_buf_errs             :integer(4)
#  lega_rx_parse_errs              :integer(4)
#  lega_rx_payloads                :string
#  lega_tx_bytes                   :integer(4)
#  lega_tx_payloads                :string
#  lega_user_agent                 :string
#  legb_disconnect_code            :integer(4)
#  legb_disconnect_reason          :string
#  legb_local_tag                  :string
#  legb_outbound_proxy             :string
#  legb_ruri                       :string
#  legb_rx_bytes                   :integer(4)
#  legb_rx_decode_errs             :integer(4)
#  legb_rx_no_buf_errs             :integer(4)
#  legb_rx_parse_errs              :integer(4)
#  legb_rx_payloads                :string
#  legb_tx_bytes                   :integer(4)
#  legb_tx_payloads                :string
#  legb_user_agent                 :string
#  local_tag                       :string
#  lrn                             :string
#  p_charge_info_in                :string
#  pai_in                          :string
#  pai_out                         :string
#  pdd                             :float
#  ppi_in                          :string
#  ppi_out                         :string
#  privacy_in                      :string
#  privacy_out                     :string
#  profit                          :decimal(, )
#  routing_attempt                 :integer(4)
#  routing_delay                   :float
#  routing_tag_ids                 :integer(2)       is an Array
#  rpid_in                         :string
#  rpid_out                        :string
#  rpid_privacy_in                 :string
#  rpid_privacy_out                :string
#  rtt                             :float
#  ruri_domain                     :string
#  sign_orig_ip                    :string
#  sign_orig_local_ip              :string
#  sign_orig_local_port            :integer(4)
#  sign_orig_port                  :integer(4)
#  sign_term_ip                    :string
#  sign_term_local_ip              :string
#  sign_term_local_port            :integer(4)
#  sign_term_port                  :integer(4)
#  src_name_in                     :string
#  src_name_out                    :string
#  src_prefix_in                   :string
#  src_prefix_out                  :string
#  src_prefix_routing              :string
#  success                         :boolean
#  time_connect                    :datetime
#  time_end                        :datetime
#  time_limit                      :string
#  time_start                      :datetime         not null
#  to_domain                       :string
#  uuid                            :uuid
#  vendor_duration                 :integer(4)
#  vendor_price                    :decimal(, )
#  yeti_version                    :string
#  auth_orig_transport_protocol_id :integer(2)
#  customer_acc_external_id        :bigint(8)
#  customer_acc_id                 :integer(4)
#  customer_auth_external_id       :bigint(8)
#  customer_auth_id                :integer(4)
#  customer_external_id            :bigint(8)
#  customer_id                     :integer(4)
#  customer_invoice_id             :integer(4)
#  destination_id                  :integer(4)
#  destination_rate_policy_id      :integer(4)
#  dialpeer_id                     :integer(4)
#  disconnect_initiator_id         :integer(4)
#  dst_area_id                     :integer(4)
#  dst_country_id                  :integer(4)
#  dst_network_id                  :integer(4)
#  dump_level_id                   :integer(4)       default(0), not null
#  failed_resource_id              :bigint(8)
#  failed_resource_type_id         :integer(2)
#  lnp_database_id                 :integer(2)
#  node_id                         :integer(4)
#  orig_call_id                    :string
#  orig_gw_external_id             :bigint(8)
#  orig_gw_id                      :integer(4)
#  pop_id                          :integer(4)
#  rateplan_id                     :integer(4)
#  routing_group_id                :integer(4)
#  routing_plan_id                 :integer(4)
#  sign_orig_transport_protocol_id :integer(2)
#  sign_term_transport_protocol_id :integer(2)
#  src_area_id                     :integer(4)
#  src_country_id                  :integer(4)
#  src_network_id                  :integer(4)
#  term_call_id                    :string
#  term_gw_external_id             :bigint(8)
#  term_gw_id                      :integer(4)
#  vendor_acc_external_id          :bigint(8)
#  vendor_acc_id                   :integer(4)
#  vendor_external_id              :bigint(8)
#  vendor_id                       :integer(4)
#  vendor_invoice_id               :integer(4)
#

class Report::Realtime::BadRouting < Report::Realtime::Base
  scope :detailed_scope, lambda {
    select("
      row_number() over (partition by customer_id, customer_auth_id, rateplan_id, routing_plan_id, internal_disconnect_code, internal_disconnect_reason) AS id,
      customer_id,
      customer_auth_id,
      rateplan_id,
      routing_plan_id,
      internal_disconnect_code,
      internal_disconnect_reason,
      count(id) as calls_count
    ").where(
      'customer_auth_id is not null AND disconnect_initiator_id=0'
    ).group(
      :customer_id,
      :customer_auth_id,
      :rateplan_id,
      :routing_plan_id,
      :internal_disconnect_code,
      :internal_disconnect_reason
    ).preload(
      :customer,
      :customer_auth,
      :rateplan,
      :routing_plan
    )
  }

  scope :time_interval_eq, lambda { |value|
    where('time_start >=(now()-\'? seconds\'::interval) and time_start < (now()-\'? seconds\'::interval)', 2 * value.to_i, value.to_i)
  }

  private

  def self.ransackable_scopes(_auth_object = nil)
    [
      :time_interval_eq
    ]
  end
end
