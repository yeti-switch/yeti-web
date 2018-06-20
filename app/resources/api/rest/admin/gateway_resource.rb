class Api::Rest::Admin::GatewayResource < JSONAPI::Resource
  attributes :name, :enabled, :priority, :weight, :acd_limit, :asr_limit, :allow_origination, :allow_termination, :sst_enabled,
             :host, :port, :resolve_ruri, :diversion_rewrite_rule, :diversion_rewrite_result,
             :src_name_rewrite_rule, :src_name_rewrite_result, :src_rewrite_rule, :src_rewrite_result,
             :dst_rewrite_rule, :dst_rewrite_result, :auth_enabled, :auth_user, :auth_password, :auth_from_user,
             :auth_from_domain, :term_use_outbound_proxy, :term_force_outbound_proxy, :term_outbound_proxy,
             :term_next_hop_for_replies, :term_next_hop, :term_append_headers_req,
             :sdp_alines_filter_list, :ringing_timeout, :relay_options, :relay_reinvite, :relay_hold, :relay_prack,
             :relay_update, :suppress_early_media, :fake_180_timer, :transit_headers_from_origination,
             :transit_headers_from_termination, :sip_interface_name, :allow_1xx_without_to_tag, :sip_timer_b,
             :dns_srv_failover_timer, :anonymize_sdp, :proxy_media, :single_codec_in_200ok, :transparent_seqno,
             :transparent_ssrc, :force_symmetric_rtp, :symmetric_rtp_nonstop, :symmetric_rtp_ignore_rtcp,
             :force_dtmf_relay, :rtp_ping, :rtp_timeout, :filter_noaudio_streams, :rtp_relay_timestamp_aligning,
             :rtp_force_relay_cn

  has_one :contractor
  has_one :session_refresh_method
  has_one :sdp_alines_filter_type, class_name: 'FilterType'
  has_one :term_disconnect_policy, class_name: 'DisconnectPolicy'
  has_one :gateway_group
  has_one :diversion_policy
  has_one :pop
  has_one :codec_group
  has_one :sdp_c_location, class_name: 'SdpCLocation'
  has_one :sensor, class_name: 'System::Sensor'
  has_one :sensor_level, class_name: 'System::SensorLevel'
  has_one :dtmf_receive_mode, class_name: 'System::DtmfReceiveMode'
  has_one :dtmf_send_mode, class_name: 'System::DtmfSendMode'
  has_one :transport_protocol, class_name: 'Equipment::TransportProtocol'
  has_one :term_proxy_transport_protocol, class_name: 'Equipment::TransportProtocol'
  has_one :orig_proxy_transport_protocol, class_name: 'Equipment::TransportProtocol'
  has_one :rel100_mode, class_name: 'Equipment::GatewayRel100Mode'
  has_one :rx_inbound_dtmf_filtering_mode, class_name: 'Equipment::GatewayInboundDtmfFilteringMode'
  has_one :tx_inbound_dtmf_filtering_mode, class_name: 'Equipment::GatewayInboundDtmfFilteringMode'


  filter :name

  def self.updatable_fields(context)
    [
      :name,
      :enabled,
      :priority,
      :acd_limit,
      :asr_limit,
      :contractor,
      :sdp_alines_filter_type,
      :codec_group,
      :sdp_c_location,
      :sensor_level,
      :dtmf_receive_mode,
      :dtmf_send_mode,
      :rx_inbound_dtmf_filtering_mode,
      :tx_inbound_dtmf_filtering_mode,
      :rel100_mode,
      :session_refresh_method,
      :transport_protocol,
      :term_proxy_transport_protocol,
      :orig_proxy_transport_protocol,
      :gateway_group,
      :pop,
      :allow_origination,
      :allow_termination,
      :sst_enabled,
      :sensor,
      :host,
      :port,
      :resolve_ruri,
      :diversion_policy,
      :diversion_rewrite_rule,
      :diversion_rewrite_result,
      :src_name_rewrite_rule,
      :src_name_rewrite_result,
      :src_rewrite_rule,
      :src_rewrite_result,
      :dst_rewrite_rule,
      :dst_rewrite_result,
      :auth_enabled,
      :auth_user,
      :auth_password,
      :auth_from_user,
      :auth_from_domain,
      :term_use_outbound_proxy,
      :term_force_outbound_proxy,
      :term_outbound_proxy,
      :term_next_hop_for_replies,
      :term_next_hop,
      :term_disconnect_policy,
      :term_append_headers_req,
      :sdp_alines_filter_list,
      :ringing_timeout,
      :relay_options,
      :relay_reinvite,
      :relay_hold,
      :relay_prack,
      :relay_update,
      :suppress_early_media,
      :fake_180_timer,
      :transit_headers_from_origination,
      :transit_headers_from_termination,
      :sip_interface_name,
      :allow_1xx_without_to_tag,
      :sip_timer_b,
      :dns_srv_failover_timer,
      :anonymize_sdp,
      :proxy_media,
      :single_codec_in_200ok,
      :transparent_seqno,
      :transparent_ssrc,
      :force_symmetric_rtp,
      :symmetric_rtp_nonstop,
      :symmetric_rtp_ignore_rtcp,
      :force_dtmf_relay,
      :rtp_ping,
      :rtp_timeout,
      :filter_noaudio_streams,
      :rtp_relay_timestamp_aligning,
      :rtp_force_relay_cn
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
