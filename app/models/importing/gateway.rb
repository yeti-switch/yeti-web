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

class Importing::Gateway < Importing::Base
  self.table_name = 'data_import.import_gateways'
  attr_accessor :file

  belongs_to :contractor, class_name: '::Contractor', optional: true
  belongs_to :session_refresh_method, class_name: '::SessionRefreshMethod', optional: true
  belongs_to :sdp_alines_filter_type, class_name: '::FilterType', foreign_key: :sdp_alines_filter_type_id, optional: true
  belongs_to :orig_disconnect_policy, class_name: '::DisconnectPolicy', foreign_key: :orig_disconnect_policy_id, optional: true
  belongs_to :term_disconnect_policy, class_name: '::DisconnectPolicy', foreign_key: :term_disconnect_policy_id, optional: true
  belongs_to :gateway_group, class_name: '::GatewayGroup', optional: true
  belongs_to :diversion_send_mode, class_name: '::Equipment::GatewayDiversionSendMode', optional: true
  belongs_to :pop, class_name: '::Pop', optional: true
  belongs_to :codec_group, class_name: '::CodecGroup', optional: true
  belongs_to :sdp_c_location, class_name: '::SdpCLocation', optional: true
  belongs_to :sensor, class_name: '::System::Sensor', foreign_key: :sensor_id, optional: true
  belongs_to :sensor_level, class_name: '::System::SensorLevel', foreign_key: :sensor_level_id, optional: true
  belongs_to :dtmf_receive_mode, class_name: '::System::DtmfReceiveMode', foreign_key: :dtmf_receive_mode_id, optional: true
  belongs_to :dtmf_send_mode, class_name: '::System::DtmfSendMode', foreign_key: :dtmf_send_mode_id, optional: true
  belongs_to :transport_protocol, class_name: '::Equipment::TransportProtocol', foreign_key: :transport_protocol_id, optional: true
  belongs_to :term_proxy_transport_protocol, class_name: '::Equipment::TransportProtocol', foreign_key: :term_proxy_transport_protocol_id, optional: true
  belongs_to :orig_proxy_transport_protocol, class_name: '::Equipment::TransportProtocol', foreign_key: :orig_proxy_transport_protocol_id, optional: true
  belongs_to :rel100_mode, class_name: '::Equipment::GatewayRel100Mode', foreign_key: :rel100_mode_id, optional: true
  belongs_to :rx_inband_dtmf_filtering_mode, class_name: '::Equipment::GatewayInbandDtmfFilteringMode', foreign_key: :rx_inband_dtmf_filtering_mode_id, optional: true
  belongs_to :tx_inband_dtmf_filtering_mode, class_name: '::Equipment::GatewayInbandDtmfFilteringMode', foreign_key: :tx_inband_dtmf_filtering_mode_id, optional: true
  belongs_to :termination_dst_numberlist, class_name: '::Routing::Numberlist', foreign_key: :termination_dst_numberlist_id, optional: true
  belongs_to :termination_src_numberlist, class_name: '::Routing::Numberlist', foreign_key: :termination_src_numberlist_id, optional: true
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id, optional: true

  self.import_attributes = %w[
    name enabled
    gateway_group_id
    contractor_id
    is_shared
    priority
    weight
    pop_id
    sip_schema_id
    host port
    origination_capacity
    termination_capacity
    diversion_send_mode_id
    diversion_domain
    diversion_rewrite_rule diversion_rewrite_result
    src_name_rewrite_rule src_name_rewrite_result
    src_rewrite_rule src_rewrite_result
    dst_rewrite_rule dst_rewrite_result
    to_rewrite_rule to_rewrite_result
    acd_limit asr_limit short_calls_limit
    allow_termination allow_origination
    proxy_media
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
    force_dtmf_relay rtp_ping
    rtp_timeout filter_noaudio_streams rtp_relay_timestamp_aligning
    rtp_force_relay_cn
    dtmf_receive_mode_id dtmf_send_mode_id
    tx_inband_dtmf_filtering_mode_id rx_inband_dtmf_filtering_mode_id
    transport_protocol_id
    term_proxy_transport_protocol_id
    orig_proxy_transport_protocol_id
    rel100_mode_id
    incoming_auth_username
    incoming_auth_password
    preserve_anonymous_from_domain
    termination_dst_numberlist_id
    termination_src_numberlist_id
    lua_script_id
    registered_aor_mode_id
    force_cancel_routeset
  ]

  import_for ::Gateway

  def registered_aor_mode_display_name
    registered_aor_mode_id.nil? ? 'unknown' : Gateway::REGISTERED_AOR_MODES[registered_aor_mode_id]
  end

  def sip_schema_display_name
    sip_schema_id.nil? ? 'unknown' : Gateway::SIP_SCHEMAS[sip_schema_id]
  end

  def self.after_import_hook
    resolve_integer_constant('registered_aor_mode_id', 'registered_aor_mode_name', Gateway::REGISTERED_AOR_MODES)
    resolve_integer_constant('sip_schema_id', 'sip_schema_name', Gateway::SIP_SCHEMAS)
    super
  end
end
