# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_gateways
#
#  host                               :string
#  port                               :integer
#  src_rewrite_rule                   :string
#  dst_rewrite_rule                   :string
#  acd_limit                          :float
#  asr_limit                          :float
#  enabled                            :boolean
#  name                               :string
#  auth_enabled                       :boolean
#  auth_user                          :string
#  auth_password                      :string
#  term_outbound_proxy                :string
#  term_next_hop_for_replies          :boolean
#  term_use_outbound_proxy            :boolean
#  contractor_id                      :integer
#  allow_termination                  :boolean
#  allow_origination                  :boolean
#  anonymize_sdp                      :boolean
#  proxy_media                        :boolean
#  transparent_seqno                  :boolean
#  transparent_ssrc                   :boolean
#  sst_enabled                        :boolean
#  sst_minimum_timer                  :integer
#  sst_maximum_timer                  :integer
#  sst_accept501                      :boolean
#  session_refresh_method_id          :integer
#  sst_session_expires                :integer
#  term_force_outbound_proxy          :boolean
#  locked                             :boolean
#  codecs_payload_order               :string
#  codecs_prefer_transcoding_for      :string
#  src_rewrite_result                 :string
#  dst_rewrite_result                 :string
#  term_next_hop                      :string
#  orig_next_hop                      :string
#  orig_append_headers_req            :string
#  term_append_headers_req            :string
#  dialog_nat_handling                :boolean
#  orig_force_outbound_proxy          :boolean
#  orig_use_outbound_proxy            :boolean
#  orig_outbound_proxy                :string
#  prefer_existing_codecs             :boolean
#  force_symmetric_rtp                :boolean
#  transparent_dialog_id              :boolean
#  sdp_alines_filter_type_id          :integer
#  sdp_alines_filter_list             :string
#  gateway_group_id                   :integer
#  orig_disconnect_policy_id          :integer
#  term_disconnect_policy_id          :integer
#  diversion_policy_id                :integer
#  diversion_rewrite_rule             :string
#  diversion_rewrite_result           :string
#  src_name_rewrite_rule              :string
#  src_name_rewrite_result            :string
#  priority                           :integer
#  pop_id                             :integer
#  id                                 :integer          not null, primary key
#  o_id                               :integer
#  gateway_group_name                 :string
#  contractor_name                    :string
#  pop_name                           :string
#  session_refresh_method_name        :string
#  sdp_alines_filter_type_name        :string
#  orig_disconnect_policy_name        :string
#  term_disconnect_policy_name        :string
#  diversion_policy_name              :string
#  error_string                       :string
#  codec_group_id                     :integer
#  codec_group_name                   :string
#  single_codec_in_200ok              :boolean
#  ringing_timeout                    :integer
#  symmetric_rtp_nonstop              :boolean
#  symmetric_rtp_ignore_rtcp          :boolean
#  resolve_ruri                       :boolean
#  force_dtmf_relay                   :boolean
#  relay_options                      :boolean
#  rtp_ping                           :boolean
#  filter_noaudio_streams             :boolean
#  relay_reinvite                     :boolean
#  sdp_c_location_id                  :integer
#  sdp_c_location_name                :string
#  auth_from_user                     :string
#  auth_from_domain                   :string
#  relay_hold                         :boolean
#  rtp_timeout                        :integer
#  relay_prack                        :boolean
#  rtp_relay_timestamp_aligning       :boolean
#  allow_1xx_without_to_tag           :boolean
#  sip_timer_b                        :integer
#  dns_srv_failover_timer             :integer
#  rtp_force_relay_cn                 :boolean
#  sensor_id                          :integer
#  sensor_name                        :string
#  sensor_level_id                    :integer
#  sensor_level_name                  :string
#  dtmf_send_mode_id                  :integer
#  dtmf_send_mode_name                :string
#  dtmf_receive_mode_id               :integer
#  dtmf_receive_mode_name             :string
#  transport_protocol_id              :integer
#  term_proxy_transport_protocol_id   :integer
#  orig_proxy_transport_protocol_id   :integer
#  transport_protocol_name            :string
#  term_proxy_transport_protocol_name :string
#  orig_proxy_transport_protocol_name :string
#  short_calls_limit                  :float
#  origination_capacity               :integer
#  termination_capacity               :integer
#  rel100_mode_id                     :integer
#  rel100_mode_name                   :string
#  is_shared                          :boolean
#  incoming_auth_username             :string
#  incoming_auth_password             :string
#  relay_update                       :boolean
#  suppress_early_media               :boolean
#  send_lnp_information               :boolean
#  force_one_way_early_media          :boolean
#  max_30x_redirects                  :integer
#  rx_inband_dtmf_filtering_mode_id   :integer
#  rx_inband_dtmf_filtering_mode_name :string
#  tx_inband_dtmf_filtering_mode_id   :integer
#  tx_inband_dtmf_filtering_mode_name :string
#  weight                             :integer
#  sip_schema_id                      :integer
#  sip_schema_name                    :string
#  network_protocol_priority_id       :integer
#  network_protocol_priority_name     :string
#  media_encryption_mode_id           :integer
#  media_encryption_mode_name         :string
#  preserve_anonymous_from_domain     :boolean
#  termination_src_numberlist_id      :integer
#  termination_src_numberlist_name    :string
#  termination_dst_numberlist_id      :integer
#  termination_dst_numberlist_name    :string
#

class Importing::Gateway < Importing::Base
  self.table_name = 'data_import.import_gateways'
  attr_accessor :file

  belongs_to :contractor, class_name: '::Contractor'
  belongs_to :session_refresh_method, class_name: '::SessionRefreshMethod'
  belongs_to :sdp_alines_filter_type, class_name: '::FilterType', foreign_key: :sdp_alines_filter_type_id
  belongs_to :orig_disconnect_policy, class_name: '::DisconnectPolicy', foreign_key: :orig_disconnect_policy_id
  belongs_to :term_disconnect_policy, class_name: '::DisconnectPolicy', foreign_key: :term_disconnect_policy_id
  belongs_to :gateway_group, class_name: '::GatewayGroup'
  belongs_to :diversion_policy, class_name: '::DiversionPolicy'
  belongs_to :pop, class_name: '::Pop'
  belongs_to :codec_group, class_name: '::CodecGroup'
  belongs_to :sdp_c_location, class_name: '::SdpCLocation'
  belongs_to :sensor, class_name: '::System::Sensor', foreign_key: :sensor_id
  belongs_to :sensor_level, class_name: '::System::SensorLevel', foreign_key: :sensor_level_id
  belongs_to :dtmf_receive_mode, class_name: '::System::DtmfReceiveMode', foreign_key: :dtmf_receive_mode_id
  belongs_to :dtmf_send_mode, class_name: '::System::DtmfSendMode', foreign_key: :dtmf_send_mode_id
  belongs_to :transport_protocol, class_name: '::Equipment::TransportProtocol', foreign_key: :transport_protocol_id
  belongs_to :term_proxy_transport_protocol, class_name: '::Equipment::TransportProtocol', foreign_key: :term_proxy_transport_protocol_id
  belongs_to :orig_proxy_transport_protocol, class_name: '::Equipment::TransportProtocol', foreign_key: :orig_proxy_transport_protocol_id
  belongs_to :rel100_mode, class_name: '::Equipment::GatewayRel100Mode', foreign_key: :rel100_mode_id
  belongs_to :rx_inband_dtmf_filtering_mode, class_name: 'GatewayInbandDtmfFilteringMode', foreign_key: :rx_inband_dtmf_filtering_mode_id
  belongs_to :tx_inband_dtmf_filtering_mode, class_name: 'GatewayInbandDtmfFilteringMode', foreign_key: :tx_inband_dtmf_filtering_mode_id
  belongs_to :termination_dst_numberlist, class_name: 'Routing::Numberlist', foreign_key: :termination_dst_numberlist_id
  belongs_to :termination_src_numberlist, class_name: 'Routing::Numberlist', foreign_key: :termination_src_numberlist_id

  self.import_attributes = %w[
    name enabled
    gateway_group_id
    contractor_id
    is_shared
    priority
    weight
    pop_id
    host port
    origination_capacity
    termination_capacity
    diversion_policy_id
    diversion_rewrite_rule diversion_rewrite_result
    src_name_rewrite_rule src_name_rewrite_result
    src_rewrite_rule src_rewrite_result
    dst_rewrite_rule dst_rewrite_result
    acd_limit asr_limit short_calls_limit
    allow_termination allow_origination
    anonymize_sdp proxy_media
    transparent_seqno transparent_ssrc
    auth_enabled auth_user auth_password
    term_use_outbound_proxy term_outbound_proxy term_force_outbound_proxy
    term_next_hop orig_next_hop
    term_append_headers_req orig_append_headers_req
    sdp_alines_filter_type_id
    sdp_alines_filter_list
    term_next_hop_for_replies
    session_refresh_method_id
    sst_enabled sst_accept501
    sst_session_expires sst_minimum_timer sst_maximum_timer
    orig_disconnect_policy_id
    term_disconnect_policy_id
    sensor_level_id sensor_id
    orig_use_outbound_proxy orig_force_outbound_proxy orig_outbound_proxy
    dialog_nat_handling
    resolve_ruri
    auth_from_user auth_from_domain
    ringing_timeout
    relay_options relay_reinvite relay_hold relay_prack allow_1xx_without_to_tag
    sip_timer_b dns_srv_failover_timer
    sdp_c_location_id codec_group_id
    single_codec_in_200ok force_symmetric_rtp symmetric_rtp_nonstop
    symmetric_rtp_ignore_rtcp force_dtmf_relay rtp_ping
    rtp_timeout filter_noaudio_streams rtp_relay_timestamp_aligning
    rtp_force_relay_cn
    dtmf_receive_mode_id dtmf_send_mode_id
    tx_inband_dtmf_filtering_mode_id rx_inband_dtmf_filtering_mode_id
    transport_protocol_id
    term_proxy_transport_protocol_id
    orig_proxy_transport_protocol_id
    rel_100_mode_id
    incoming_auth_username
    incoming_auth_password
    preserve_anonymous_from_domain
    termination_dst_numberlist_id
    termination_src_numberlist_id
  ]

  self.import_class = ::Gateway
end
