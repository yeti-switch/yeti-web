FactoryGirl.define do
  factory :gateway, class: Gateway do
    sequence(:name) { |n| "gateway#{n}" }
    enabled true
    priority 122
    weight 220
    acd_limit 0.0
    asr_limit 0.0
    sdp_alines_filter_type_id 0
    session_refresh_method_id 1
    sdp_c_location_id 2
    sensor_level_id 1
    dtmf_receive_mode_id 1
    dtmf_send_mode_id 1
    rel100_mode_id 1
    transport_protocol_id 1
    term_proxy_transport_protocol_id 1
    orig_proxy_transport_protocol_id 1
    host "test.example.com"
    port nil
    src_rewrite_rule nil
    dst_rewrite_rule nil
    auth_enabled false
    auth_user nil
    auth_password nil
    term_outbound_proxy nil
    term_next_hop_for_replies false
    term_use_outbound_proxy false
    allow_termination true
    allow_origination true
    anonymize_sdp true
    proxy_media true
    transparent_seqno false
    transparent_ssrc false
    sst_enabled false
    sst_minimum_timer 50
    sst_maximum_timer 50
    sst_accept501 true
    sst_session_expires 50
    term_force_outbound_proxy false
    locked false
    codecs_payload_order ''
    codecs_prefer_transcoding_for nil
    src_rewrite_result nil
    dst_rewrite_result nil
    term_next_hop nil
    orig_next_hop nil
    orig_append_headers_req nil
    term_append_headers_req nil
    dialog_nat_handling true
    orig_force_outbound_proxy false
    orig_use_outbound_proxy false
    orig_outbound_proxy nil
    prefer_existing_codecs true
    force_symmetric_rtp true
    transparent_dialog_id false
    sdp_alines_filter_list nil
    gateway_group_id nil
    orig_disconnect_policy_id nil
    term_disconnect_policy_id nil
    diversion_policy_id 1
    diversion_rewrite_rule nil
    diversion_rewrite_result nil
    src_name_rewrite_rule nil
    src_name_rewrite_result nil
    pop_id nil
    single_codec_in_200ok false
    ringing_timeout nil
    symmetric_rtp_nonstop false
    symmetric_rtp_ignore_rtcp false
    resolve_ruri false
    force_dtmf_relay false
    relay_options false
    rtp_ping false
    relay_reinvite false
    auth_from_user nil
    auth_from_domain nil
    relay_hold false
    rtp_timeout 30
    relay_prack false
    rtp_relay_timestamp_aligning false
    allow_1xx_without_to_tag false
    sip_timer_b 8000
    dns_srv_failover_timer 2000
    rtp_force_relay_cn true
    sensor_id nil
    filter_noaudio_streams false

    association :contractor, factory: :contractor, vendor: true
    codec_group { CodecGroup.take || association(:codec_group) }


    trait :with_incoming_auth do
      incoming_auth_username "incoming_username"
      incoming_auth_password "incoming_password"
    end

    trait :without_incoming_auth do
      incoming_auth_username  nil
      incoming_auth_password  nil
    end

  end
end
