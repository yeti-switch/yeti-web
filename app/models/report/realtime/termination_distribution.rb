# == Schema Information
#
# Table name: cdr.cdr
#
#  id                              :integer          not null, primary key
#  customer_id                     :integer
#  vendor_id                       :integer
#  customer_acc_id                 :integer
#  vendor_acc_id                   :integer
#  customer_auth_id                :integer
#  destination_id                  :integer
#  dialpeer_id                     :integer
#  orig_gw_id                      :integer
#  term_gw_id                      :integer
#  routing_group_id                :integer
#  rateplan_id                     :integer
#  destination_next_rate           :decimal(, )
#  destination_fee                 :decimal(, )
#  dialpeer_next_rate              :decimal(, )
#  dialpeer_fee                    :decimal(, )
#  time_limit                      :string
#  internal_disconnect_code        :integer
#  internal_disconnect_reason      :string
#  disconnect_initiator_id         :integer
#  customer_price                  :decimal(, )
#  vendor_price                    :decimal(, )
#  duration                        :integer
#  success                         :boolean
#  profit                          :decimal(, )
#  dst_prefix_in                   :string
#  dst_prefix_out                  :string
#  src_prefix_in                   :string
#  src_prefix_out                  :string
#  time_start                      :datetime
#  time_connect                    :datetime
#  time_end                        :datetime
#  sign_orig_ip                    :string
#  sign_orig_port                  :integer
#  sign_orig_local_ip              :string
#  sign_orig_local_port            :integer
#  sign_term_ip                    :string
#  sign_term_port                  :integer
#  sign_term_local_ip              :string
#  sign_term_local_port            :integer
#  orig_call_id                    :string
#  term_call_id                    :string
#  vendor_invoice_id               :integer
#  customer_invoice_id             :integer
#  local_tag                       :string
#  destination_initial_rate        :decimal(, )
#  dialpeer_initial_rate           :decimal(, )
#  destination_initial_interval    :integer
#  destination_next_interval       :integer
#  dialpeer_initial_interval       :integer
#  dialpeer_next_interval          :integer
#  destination_rate_policy_id      :integer
#  routing_attempt                 :integer
#  is_last_cdr                     :boolean
#  lega_disconnect_code            :integer
#  lega_disconnect_reason          :string
#  pop_id                          :integer
#  node_id                         :integer
#  src_name_in                     :string
#  src_name_out                    :string
#  diversion_in                    :string
#  diversion_out                   :string
#  lega_rx_payloads                :string
#  lega_tx_payloads                :string
#  legb_rx_payloads                :string
#  legb_tx_payloads                :string
#  legb_disconnect_code            :integer
#  legb_disconnect_reason          :string
#  dump_level_id                   :integer          default(0), not null
#  auth_orig_ip                    :inet
#  auth_orig_port                  :integer
#  lega_rx_bytes                   :integer
#  lega_tx_bytes                   :integer
#  legb_rx_bytes                   :integer
#  legb_tx_bytes                   :integer
#  global_tag                      :string
#  dst_country_id                  :integer
#  dst_network_id                  :integer
#  lega_rx_decode_errs             :integer
#  lega_rx_no_buf_errs             :integer
#  lega_rx_parse_errs              :integer
#  legb_rx_decode_errs             :integer
#  legb_rx_no_buf_errs             :integer
#  legb_rx_parse_errs              :integer
#  src_prefix_routing              :string
#  dst_prefix_routing              :string
#  routing_plan_id                 :integer
#  routing_delay                   :float
#  pdd                             :float
#  rtt                             :float
#  early_media_present             :boolean
#  lnp_database_id                 :integer
#  lrn                             :string
#  destination_prefix              :string
#  dialpeer_prefix                 :string
#  audio_recorded                  :boolean
#  ruri_domain                     :string
#  to_domain                       :string
#  from_domain                     :string
#  src_area_id                     :integer
#  dst_area_id                     :integer
#  auth_orig_transport_protocol_id :integer
#  sign_orig_transport_protocol_id :integer
#  sign_term_transport_protocol_id :integer
#  core_version                    :string
#  yeti_version                    :string
#  lega_user_agent                 :string
#  legb_user_agent                 :string
#  uuid                            :uuid
#  pai_in                          :string
#  ppi_in                          :string
#  privacy_in                      :string
#  rpid_in                         :string
#  rpid_privacy_in                 :string
#  pai_out                         :string
#  ppi_out                         :string
#  privacy_out                     :string
#  rpid_out                        :string
#  rpid_privacy_out                :string
#  destination_reverse_billing     :boolean
#  dialpeer_reverse_billing        :boolean
#  is_redirected                   :boolean
#  customer_account_check_balance  :boolean
#  customer_external_id            :integer
#  customer_auth_external_id       :integer
#  customer_acc_vat                :decimal(, )
#  customer_acc_external_id        :integer
#  routing_tag_ids                 :integer          is an Array
#  vendor_external_id              :integer
#  vendor_acc_external_id          :integer
#  orig_gw_external_id             :integer
#  term_gw_external_id             :integer
#  failed_resource_type_id         :integer
#  failed_resource_id              :integer
#  customer_price_no_vat           :decimal(, )
#  customer_duration               :integer
#  vendor_duration                 :integer
#  customer_auth_name              :string
#

class Report::Realtime::TerminationDistribution < Report::Realtime::Base

  scope :detailed_scope, -> do
    select('
      vendor_id,
      count(nullif(is_last_cdr,false)) as originated_calls_count,
      count(nullif(routing_attempt=2,false)) as rerouted_calls_count,
      100*count(nullif(routing_attempt=2,false))::real/nullif(count(nullif(is_last_cdr,false)),0)::real as rerouted_calls_percent,
      count(id) as termination_attempts_count,
      coalesce(sum(duration),0) as calls_duration,
      sum(duration)::float/nullif(count(nullif(success,false)),0)::float as acd,
      count(nullif(success,false))::float/nullif(count(nullif(is_last_cdr,false)),0)::float as origination_asr,
      count(nullif(success,false))::float/nullif(count(id),0)::float as termination_asr,
      sum(profit) as profit,
      sum(customer_price) as customer_price,
      sum(vendor_price) as vendor_price
    ').group(:vendor_id).preload(:vendor)
  end

  scope :time_interval_eq, ->(value) do
    where('time_start >=? and time_start <?', value.to_i.seconds.ago, Time.now)
  end

  private

  def self.ransackable_scopes(auth_object = nil)
    [
        :time_interval_eq
    ]
  end

end
