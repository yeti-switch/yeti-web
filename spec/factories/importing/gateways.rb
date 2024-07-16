# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_gateways
#
#  id                                 :integer(4)       not null, primary key
#  acd_limit                          :float
#  allow_1xx_without_to_tag           :boolean
#  allow_origination                  :boolean
#  allow_termination                  :boolean
#  asr_limit                          :float
#  auth_enabled                       :boolean
#  auth_from_domain                   :string
#  auth_from_user                     :string
#  auth_password                      :string
#  auth_user                          :string
#  codec_group_name                   :string
#  codecs_payload_order               :string
#  codecs_prefer_transcoding_for      :string
#  contractor_name                    :string
#  dialog_nat_handling                :boolean
#  diversion_domain                   :string
#  diversion_rewrite_result           :string
#  diversion_rewrite_rule             :string
#  diversion_send_mode_name           :string
#  dns_srv_failover_timer             :integer(4)
#  dst_rewrite_result                 :string
#  dst_rewrite_rule                   :string
#  dtmf_receive_mode_name             :string
#  dtmf_send_mode_name                :string
#  enabled                            :boolean
#  error_string                       :string
#  filter_noaudio_streams             :boolean
#  force_cancel_routeset              :boolean
#  force_dtmf_relay                   :boolean
#  force_one_way_early_media          :boolean
#  force_symmetric_rtp                :boolean
#  gateway_group_name                 :string
#  host                               :string
#  incoming_auth_password             :string
#  incoming_auth_username             :string
#  is_changed                         :boolean
#  is_shared                          :boolean
#  locked                             :boolean
#  lua_script_name                    :string
#  max_30x_redirects                  :integer(4)
#  media_encryption_mode_name         :string
#  name                               :string
#  network_protocol_priority_name     :string
#  orig_append_headers_req            :string
#  orig_disconnect_policy_name        :string
#  orig_force_outbound_proxy          :boolean
#  orig_next_hop                      :string
#  orig_outbound_proxy                :string
#  orig_proxy_transport_protocol_name :string
#  orig_use_outbound_proxy            :boolean
#  origination_capacity               :integer(2)
#  pop_name                           :string
#  port                               :integer(4)
#  prefer_existing_codecs             :boolean
#  preserve_anonymous_from_domain     :boolean
#  priority                           :integer(4)
#  proxy_media                        :boolean
#  registered_aor_mode_name           :string
#  rel100_mode_name                   :string
#  relay_hold                         :boolean
#  relay_options                      :boolean
#  relay_prack                        :boolean
#  relay_reinvite                     :boolean
#  relay_update                       :boolean
#  resolve_ruri                       :boolean
#  ringing_timeout                    :integer(4)
#  rtp_force_relay_cn                 :boolean
#  rtp_ping                           :boolean
#  rtp_relay_timestamp_aligning       :boolean
#  rtp_timeout                        :integer(4)
#  rx_inband_dtmf_filtering_mode_name :string
#  sdp_alines_filter_list             :string
#  sdp_alines_filter_type_name        :string
#  sdp_c_location_name                :string
#  send_lnp_information               :boolean
#  sensor_level_name                  :string
#  sensor_name                        :string
#  session_refresh_method_name        :string
#  short_calls_limit                  :float
#  single_codec_in_200ok              :boolean
#  sip_schema_name                    :string
#  sip_timer_b                        :integer(4)
#  src_name_rewrite_result            :string
#  src_name_rewrite_rule              :string
#  src_rewrite_result                 :string
#  src_rewrite_rule                   :string
#  sst_accept501                      :boolean
#  sst_enabled                        :boolean
#  sst_maximum_timer                  :integer(4)
#  sst_minimum_timer                  :integer(4)
#  sst_session_expires                :integer(4)
#  suppress_early_media               :boolean
#  symmetric_rtp_nonstop              :boolean
#  term_append_headers_req            :string
#  term_disconnect_policy_name        :string
#  term_force_outbound_proxy          :boolean
#  term_next_hop                      :string
#  term_next_hop_for_replies          :boolean
#  term_outbound_proxy                :string
#  term_proxy_transport_protocol_name :string
#  term_use_outbound_proxy            :boolean
#  termination_capacity               :integer(2)
#  termination_dst_numberlist_name    :string
#  termination_src_numberlist_name    :string
#  to_rewrite_result                  :string
#  to_rewrite_rule                    :string
#  transport_protocol_name            :string
#  try_avoid_transcoding              :boolean
#  tx_inband_dtmf_filtering_mode_name :string
#  weight                             :integer(2)
#  codec_group_id                     :integer(4)
#  contractor_id                      :integer(4)
#  diversion_send_mode_id             :integer(2)
#  dtmf_receive_mode_id               :integer(2)
#  dtmf_send_mode_id                  :integer(2)
#  gateway_group_id                   :integer(4)
#  lua_script_id                      :integer(2)
#  media_encryption_mode_id           :integer(2)
#  network_protocol_priority_id       :integer(2)
#  o_id                               :integer(4)
#  orig_disconnect_policy_id          :integer(4)
#  orig_proxy_transport_protocol_id   :integer(2)
#  pop_id                             :integer(4)
#  registered_aor_mode_id             :integer(2)
#  rel100_mode_id                     :integer(2)
#  rx_inband_dtmf_filtering_mode_id   :integer(2)
#  sdp_alines_filter_type_id          :integer(4)
#  sdp_c_location_id                  :integer(4)
#  sensor_id                          :integer(2)
#  sensor_level_id                    :integer(2)
#  session_refresh_method_id          :integer(4)
#  sip_schema_id                      :integer(2)
#  term_disconnect_policy_id          :integer(4)
#  term_proxy_transport_protocol_id   :integer(2)
#  termination_dst_numberlist_id      :integer(2)
#  termination_src_numberlist_id      :integer(2)
#  transparent_dialog_id              :boolean
#  transport_protocol_id              :integer(2)
#  tx_inband_dtmf_filtering_mode_id   :integer(2)
#
FactoryBot.define do
  factory :importing_gateway, class: 'Importing::Gateway' do
    o_id { nil }
    host { nil }
    port { nil }
    src_rewrite_rule { nil }
    dst_rewrite_rule { nil }
    acd_limit { nil }
    asr_limit { nil }
    enabled { nil }
    name { nil }
    auth_enabled { false }
    auth_user { nil }
    auth_password { nil }
    term_outbound_proxy { nil }
    term_next_hop_for_replies { false }
    term_use_outbound_proxy { false }
    contractor_id { nil }
    allow_termination { true }
    allow_origination { true }
    proxy_media { true }
    sst_enabled { false }
    sst_minimum_timer { 50 }
    sst_maximum_timer { 50 }
    sst_accept501 { true }
    session_refresh_method_id { 3 }
    sst_session_expires { 50 }
    term_force_outbound_proxy { false }
    locked { false }
    codecs_payload_order { '' }
    codecs_prefer_transcoding_for { nil }
    src_rewrite_result { nil }
    dst_rewrite_result { nil }
    capacity { 0 }
    term_next_hop { nil }
    orig_next_hop { nil }
    orig_append_headers_req { nil }
    term_append_headers_req { nil }
    dialog_nat_handling { true }
    orig_force_outbound_proxy { false }
    orig_use_outbound_proxy { false }
    orig_outbound_proxy { nil }
    prefer_existing_codecs { true }
    force_symmetric_rtp { true }
    transparent_dialog_id { false }
    sdp_alines_filter_type_name { nil }
    sdp_alines_filter_type_id { 0 }
    sdp_alines_filter_list { nil }
    gateway_group_id { nil }
    orig_disconnect_policy_id { nil }
    term_disconnect_policy_id { nil }

    diversion_send_mode_id { 1 }
    diversion_send_mode_name { nil }
    diversion_domain { nil }
    diversion_rewrite_rule { nil }
    diversion_rewrite_result { nil }

    src_name_rewrite_rule { nil }
    src_name_rewrite_result { nil }
    priority { 100 }
    pop_id { nil }
    gateway_group_name { nil }
    contractor_name { nil }
    pop_name { nil }
    session_refresh_method_name { nil }
    orig_disconnect_policy_name { nil }
    term_disconnect_policy_name { nil }
    codec_group_id { 1 }
    codec_group_name { nil }
    single_codec_in_200ok { false }
    ringing_timeout { nil }
    symmetric_rtp_nonstop { false }
    resolve_ruri { false }
    force_dtmf_relay { false }
    relay_options { false }
    rtp_ping { false }
    relay_reinvite { false }
    sdp_c_location_id { 2 }
    sdp_c_location_name { nil }
    auth_from_user { nil }
    auth_from_domain { nil }
    relay_hold { false }
    rtp_timeout { 30 }
    relay_prack { false }
    rtp_relay_timestamp_aligning { false }
    allow_1xx_without_to_tag { false }
    sip_timer_b { 8000 }
    dns_srv_failover_timer { 2000 }
    rtp_force_relay_cn { true }
    sensor_id { nil }
    sensor_name { nil }
    sensor_level_id { 1 }
    sensor_level_name { nil }
    filter_noaudio_streams { false }
    error_string { nil }
    dtmf_send_mode_id { 1 }
    dtmf_send_mode_name { 'RFC 2833' }
    dtmf_receive_mode_id { 1 }
    dtmf_receive_mode_name { 'RFC 2833' }
    relay_update { true }
    suppress_early_media { true }
    send_lnp_information { true }
    force_one_way_early_media { true }
    max_30x_redirects { 1 }
    force_cancel_routeset { false }
  end
end
