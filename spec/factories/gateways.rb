# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateways
#
#  id                               :integer(4)       not null, primary key
#  acd_limit                        :float            default(0.0), not null
#  allow_1xx_without_to_tag         :boolean          default(FALSE), not null
#  allow_origination                :boolean          default(TRUE), not null
#  allow_termination                :boolean          default(TRUE), not null
#  asr_limit                        :float            default(0.0), not null
#  auth_enabled                     :boolean          default(FALSE), not null
#  auth_from_domain                 :string
#  auth_from_user                   :string
#  auth_password                    :string
#  auth_user                        :string
#  codecs_payload_order             :string           default("")
#  codecs_prefer_transcoding_for    :string           default("")
#  dialog_nat_handling              :boolean          default(TRUE), not null
#  diversion_domain                 :string
#  diversion_rewrite_result         :string
#  diversion_rewrite_rule           :string
#  dns_srv_failover_timer           :integer(4)       default(2000), not null
#  dst_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  enabled                          :boolean          not null
#  fake_180_timer                   :integer(2)
#  filter_noaudio_streams           :boolean          default(FALSE), not null
#  force_cancel_routeset            :boolean          default(FALSE), not null
#  force_dtmf_relay                 :boolean          default(FALSE), not null
#  force_one_way_early_media        :boolean          default(FALSE), not null
#  force_symmetric_rtp              :boolean          default(TRUE), not null
#  host                             :string
#  incoming_auth_allow_jwt          :boolean          default(FALSE), not null
#  incoming_auth_password           :string
#  incoming_auth_username           :string
#  is_shared                        :boolean          default(FALSE), not null
#  locked                           :boolean          default(FALSE), not null
#  max_30x_redirects                :integer(2)       default(0), not null
#  max_transfers                    :integer(2)       default(0), not null
#  name                             :string           not null
#  orig_append_headers_reply        :string           default([]), not null, is an Array
#  orig_append_headers_req          :string           default([]), not null, is an Array
#  orig_force_outbound_proxy        :boolean          default(FALSE), not null
#  orig_next_hop                    :string
#  orig_outbound_proxy              :string
#  orig_use_outbound_proxy          :boolean          default(FALSE), not null
#  origination_capacity             :integer(2)
#  pai_domain                       :string
#  port                             :integer(4)
#  prefer_existing_codecs           :boolean          default(TRUE), not null
#  preserve_anonymous_from_domain   :boolean          default(FALSE), not null
#  priority                         :integer(4)       default(100), not null
#  proxy_media                      :boolean          default(TRUE), not null
#  relay_hold                       :boolean          default(FALSE), not null
#  relay_options                    :boolean          default(FALSE), not null
#  relay_prack                      :boolean          default(FALSE), not null
#  relay_reinvite                   :boolean          default(FALSE), not null
#  relay_update                     :boolean          default(FALSE), not null
#  resolve_ruri                     :boolean          default(FALSE), not null
#  ringing_timeout                  :integer(4)
#  rtp_acl                          :inet             is an Array
#  rtp_force_relay_cn               :boolean          default(TRUE), not null
#  rtp_interface_name               :string
#  rtp_ping                         :boolean          default(FALSE), not null
#  rtp_relay_timestamp_aligning     :boolean          default(FALSE), not null
#  rtp_timeout                      :integer(4)       default(30), not null
#  sdp_alines_filter_list           :string
#  send_lnp_information             :boolean          default(FALSE), not null
#  short_calls_limit                :float            default(1.0), not null
#  single_codec_in_200ok            :boolean          default(FALSE), not null
#  sip_interface_name               :string
#  sip_timer_b                      :integer(4)       default(8000), not null
#  src_name_rewrite_result          :string
#  src_name_rewrite_rule            :string
#  src_rewrite_result               :string
#  src_rewrite_rule                 :string
#  sst_accept501                    :boolean          default(TRUE), not null
#  sst_enabled                      :boolean          default(FALSE)
#  sst_maximum_timer                :integer(4)       default(50), not null
#  sst_minimum_timer                :integer(4)       default(50), not null
#  sst_session_expires              :integer(4)       default(50)
#  suppress_early_media             :boolean          default(FALSE), not null
#  symmetric_rtp_nonstop            :boolean          default(FALSE), not null
#  term_append_headers_req          :string           default([]), not null, is an Array
#  term_force_outbound_proxy        :boolean          default(FALSE), not null
#  term_next_hop                    :string
#  term_next_hop_for_replies        :boolean          default(FALSE), not null
#  term_outbound_proxy              :string
#  term_use_outbound_proxy          :boolean          default(FALSE), not null
#  termination_capacity             :integer(2)
#  to_rewrite_result                :string
#  to_rewrite_rule                  :string
#  transit_headers_from_origination :string
#  transit_headers_from_termination :string
#  try_avoid_transcoding            :boolean          default(FALSE), not null
#  weight                           :integer(2)       default(100), not null
#  codec_group_id                   :integer(4)       default(1), not null
#  contractor_id                    :integer(4)       not null
#  diversion_send_mode_id           :integer(2)       default(1), not null
#  dtmf_receive_mode_id             :integer(2)       default(1), not null
#  dtmf_send_mode_id                :integer(2)       default(1), not null
#  external_id                      :bigint(8)
#  gateway_group_id                 :integer(4)
#  lua_script_id                    :integer(2)
#  media_encryption_mode_id         :integer(2)       default(0), not null
#  network_protocol_priority_id     :integer(2)       default(0), not null
#  orig_disconnect_policy_id        :integer(4)
#  orig_proxy_transport_protocol_id :integer(2)       default(1), not null
#  pai_send_mode_id                 :integer(2)       default(0), not null
#  pop_id                           :integer(4)
#  privacy_mode_id                  :integer(2)       default(0), not null
#  radius_accounting_profile_id     :integer(2)
#  registered_aor_mode_id           :integer(2)       default(0), not null
#  rel100_mode_id                   :integer(2)       default(4), not null
#  rx_inband_dtmf_filtering_mode_id :integer(2)       default(1), not null
#  sdp_alines_filter_type_id        :integer(4)       default(0), not null
#  sdp_c_location_id                :integer(4)       default(2), not null
#  sensor_id                        :integer(2)
#  sensor_level_id                  :integer(2)       default(1), not null
#  session_refresh_method_id        :integer(4)       default(3), not null
#  sip_schema_id                    :integer(2)       default(1), not null
#  stir_shaken_crt_id               :integer(2)
#  stir_shaken_mode_id              :integer(2)       default(0), not null
#  term_disconnect_policy_id        :integer(4)
#  term_proxy_transport_protocol_id :integer(2)       default(1), not null
#  termination_dst_numberlist_id    :integer(2)
#  termination_src_numberlist_id    :integer(2)
#  transparent_dialog_id            :boolean          default(FALSE), not null
#  transport_protocol_id            :integer(2)       default(1), not null
#  tx_inband_dtmf_filtering_mode_id :integer(2)       default(1), not null
#
# Indexes
#
#  gateways_contractor_id_idx      (contractor_id)
#  gateways_dst_numberlist_id_idx  (termination_dst_numberlist_id)
#  gateways_name_unique            (name) UNIQUE
#  gateways_src_numberlist_id_idx  (termination_src_numberlist_id)
#
# Foreign Keys
#
#  gateways_codec_group_id_fkey                    (codec_group_id => codec_groups.id)
#  gateways_contractor_id_fkey                     (contractor_id => contractors.id)
#  gateways_diversion_send_mode_id_fkey            (diversion_send_mode_id => gateway_diversion_send_modes.id)
#  gateways_dtmf_receive_mode_id_fkey              (dtmf_receive_mode_id => dtmf_receive_modes.id)
#  gateways_dtmf_send_mode_id_fkey                 (dtmf_send_mode_id => dtmf_send_modes.id)
#  gateways_gateway_group_id_fkey                  (gateway_group_id => gateway_groups.id)
#  gateways_lua_script_id_fkey                     (lua_script_id => lua_scripts.id)
#  gateways_media_encryption_mode_id_fkey          (media_encryption_mode_id => gateway_media_encryption_modes.id)
#  gateways_network_protocol_priority_id_fkey      (network_protocol_priority_id => gateway_network_protocol_priorities.id)
#  gateways_orig_disconnect_policy_id_fkey         (orig_disconnect_policy_id => disconnect_policy.id)
#  gateways_orig_proxy_transport_protocol_id_fkey  (orig_proxy_transport_protocol_id => transport_protocols.id)
#  gateways_pop_id_fkey                            (pop_id => pops.id)
#  gateways_radius_accounting_profile_id_fkey      (radius_accounting_profile_id => radius_accounting_profiles.id)
#  gateways_rel100_mode_id_fkey                    (rel100_mode_id => gateway_rel100_modes.id)
#  gateways_rx_inband_dtmf_filtering_mode_id_fkey  (rx_inband_dtmf_filtering_mode_id => gateway_inband_dtmf_filtering_modes.id)
#  gateways_sdp_alines_filter_type_id_fkey         (sdp_alines_filter_type_id => filter_types.id)
#  gateways_sdp_c_location_id_fkey                 (sdp_c_location_id => sdp_c_location.id)
#  gateways_sensor_id_fkey                         (sensor_id => sensors.id)
#  gateways_sensor_level_id_fkey                   (sensor_level_id => sensor_levels.id)
#  gateways_session_refresh_method_id_fkey         (session_refresh_method_id => session_refresh_methods.id)
#  gateways_stir_shaken_crt_id_fkey                (stir_shaken_crt_id => stir_shaken_signing_certificates.id)
#  gateways_term_disconnect_policy_id_fkey         (term_disconnect_policy_id => disconnect_policy.id)
#  gateways_term_proxy_transport_protocol_id_fkey  (term_proxy_transport_protocol_id => transport_protocols.id)
#  gateways_transport_protocol_id_fkey             (transport_protocol_id => transport_protocols.id)
#  gateways_tx_inband_dtmf_filtering_mode_id_fkey  (tx_inband_dtmf_filtering_mode_id => gateway_inband_dtmf_filtering_modes.id)
#
FactoryBot.define do
  factory :gateway, class: 'Gateway' do
    sequence(:name) { |n| "gateway#{n}" }
    enabled { true }
    priority { 122 }
    weight { 220 }
    acd_limit { 0.0 }
    asr_limit { 0.0 }
    sdp_alines_filter_type_id { 0 }
    session_refresh_method_id { 1 }
    sdp_c_location_id { 2 }
    sensor_level_id { 1 }
    dtmf_receive_mode_id { 1 }
    dtmf_send_mode_id { 1 }
    rel100_mode_id { 1 }

    network_protocol_priority_id { 1 }

    transport_protocol_id { 1 }
    term_proxy_transport_protocol_id { 1 }
    orig_proxy_transport_protocol_id { 1 }
    sip_schema_id { 1 }
    host { 'test.example.com' }
    port { nil }
    registered_aor_mode_id { 1 }
    src_rewrite_rule { nil }
    dst_rewrite_rule { nil }
    auth_enabled { false }
    auth_user { nil }
    auth_password { nil }
    term_outbound_proxy { nil }
    term_next_hop_for_replies { false }
    term_use_outbound_proxy { false }
    termination_capacity { 1 }
    allow_termination { true }
    allow_origination { true }
    proxy_media { true }
    origination_capacity { 1 }
    preserve_anonymous_from_domain { false }
    sst_enabled { false }
    sst_minimum_timer { 50 }
    sst_maximum_timer { 50 }
    sst_accept501 { true }
    sst_session_expires { 50 }
    term_force_outbound_proxy { false }
    locked { false }
    codecs_payload_order { '' }
    codecs_prefer_transcoding_for { nil }
    src_rewrite_result { nil }
    dst_rewrite_result { nil }
    term_next_hop { nil }
    orig_next_hop { nil }
    orig_append_headers_req { [] }
    orig_append_headers_reply { [] }
    term_append_headers_req { [] }
    dialog_nat_handling { true }
    orig_force_outbound_proxy { false }
    orig_use_outbound_proxy { false }
    orig_outbound_proxy { nil }
    prefer_existing_codecs { true }
    force_symmetric_rtp { true }
    transparent_dialog_id { false }
    sdp_alines_filter_list { nil }
    gateway_group_id { nil }
    orig_disconnect_policy_id { nil }
    term_disconnect_policy_id { nil }
    diversion_send_mode_id { 1 }
    diversion_domain { nil }
    diversion_rewrite_rule { nil }
    diversion_rewrite_result { nil }
    src_name_rewrite_rule { nil }
    src_name_rewrite_result { nil }
    pop_id { nil }
    single_codec_in_200ok { false }
    ringing_timeout { nil }
    symmetric_rtp_nonstop { false }
    resolve_ruri { false }
    force_dtmf_relay { false }
    relay_options { false }
    rtp_ping { false }
    relay_reinvite { false }
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
    filter_noaudio_streams { false }
    media_encryption_mode_id { 1 }
    force_cancel_routeset { false }

    association :contractor, factory: :contractor, vendor: true
    codec_group { CodecGroup.take || association(:codec_group) }

    trait :with_incoming_auth do
      incoming_auth_username { 'incoming_username' }
      incoming_auth_password { 'incoming_password' }
    end

    trait :without_incoming_auth do
      incoming_auth_username  { nil }
      incoming_auth_password  { nil }
    end

    trait :filled do
      session_refresh_method { SessionRefreshMethod.take }
      sdp_alines_filter_type { FilterType.take }
      orig_disconnect_policy { DisconnectPolicy.take || build(:disconnect_policy) }
      term_disconnect_policy { DisconnectPolicy.take || build(:disconnect_policy) }
      diversion_send_mode { Equipment::GatewayDiversionSendMode.take }
      sdp_c_location { SdpCLocation.take }
      sensor
      sensor_level { System::SensorLevel.take }
      dtmf_receive_mode { System::DtmfReceiveMode.take }
      dtmf_send_mode { System::DtmfSendMode.take }
      radius_accounting_profile { build :accounting_profile }
      transport_protocol { Equipment::TransportProtocol.take }
      term_proxy_transport_protocol { Equipment::TransportProtocol.take }
      rel100_mode { Equipment::GatewayRel100Mode.take }
      rx_inband_dtmf_filtering_mode { Equipment::GatewayInbandDtmfFilteringMode.take }
      network_protocol_priority { Equipment::GatewayNetworkProtocolPriority.take }
      media_encryption_mode { Equipment::GatewayMediaEncryptionMode.take }
      termination_dst_numberlist { build :numberlist }
      lua_script
      statistic { build :gateways_stat }

      after(:create) do |record|
        FactoryBot.create_list(:customers_auth, 2, gateway: record)
        FactoryBot.create_list(:quality_stat, 2, gateway: record)
      end
    end
  end
end
