# frozen_string_literal: true

class Api::Rest::Admin::GatewayResource < ::BaseResource
  attributes :name, :enabled, :priority, :weight, :acd_limit, :asr_limit, :allow_origination, :allow_termination, :sst_enabled,
             :host, :port, :resolve_ruri,
             :diversion_domain, :diversion_rewrite_rule, :diversion_rewrite_result,
             :src_name_rewrite_rule, :src_name_rewrite_result, :src_rewrite_rule, :src_rewrite_result,
             :dst_rewrite_rule, :dst_rewrite_result, :auth_enabled, :auth_user, :auth_password, :auth_from_user,
             :auth_from_domain, :term_use_outbound_proxy, :term_force_outbound_proxy, :term_outbound_proxy,
             :term_next_hop_for_replies, :term_next_hop, :term_append_headers_req,
             :orig_append_headers_req, :orig_append_headers_reply,
             :sdp_alines_filter_list, :ringing_timeout, :relay_options, :relay_reinvite, :relay_hold, :relay_prack,
             :relay_update, :suppress_early_media, :fake_180_timer, :transit_headers_from_origination,
             :transit_headers_from_termination, :sip_interface_name, :allow_1xx_without_to_tag, :sip_timer_b,
             :dns_srv_failover_timer, :proxy_media, :single_codec_in_200ok,
             :force_symmetric_rtp, :symmetric_rtp_nonstop,
             :force_dtmf_relay, :rtp_ping, :rtp_timeout, :filter_noaudio_streams, :rtp_relay_timestamp_aligning,
             :rtp_force_relay_cn, :preserve_anonymous_from_domain, :registered_aor_mode_id,
             :incoming_auth_username, :incoming_auth_password, :origination_capacity, :termination_capacity,
             :force_cancel_routeset, :sip_schema_id

  paginator :paged

  has_one :contractor
  has_one :session_refresh_method
  has_one :sdp_alines_filter_type, class_name: 'FilterType'
  has_one :term_disconnect_policy, class_name: 'DisconnectPolicy'
  has_one :gateway_group
  has_one :diversion_send_mode, class_name: 'Equipment::GatewayDiversionSendMode'
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
  has_one :rx_inband_dtmf_filtering_mode, class_name: 'Equipment::GatewayInbandDtmfFilteringMode'
  has_one :tx_inband_dtmf_filtering_mode, class_name: 'Equipment::GatewayInbandDtmfFilteringMode'
  has_one :network_protocol_priority, class_name: 'Equipment::GatewayNetworkProtocolPriority'
  has_one :media_encryption_mode, class_name: 'Equipment::GatewayMediaEncryptionMode'

  filter :name # DEPRECATED

  relationship_filter :contractor
  relationship_filter :session_refresh_method
  relationship_filter :sdp_alines_filter_type
  relationship_filter :term_disconnect_policy
  relationship_filter :gateway_group
  relationship_filter :diversion_send_mode
  relationship_filter :pop
  relationship_filter :codec_group
  relationship_filter :sdp_c_location
  relationship_filter :sensor
  relationship_filter :sensor_level
  relationship_filter :dtmf_receive_mode
  relationship_filter :dtmf_send_mode
  relationship_filter :transport_protocol
  relationship_filter :term_proxy_transport_protocol
  relationship_filter :orig_proxy_transport_protocol
  relationship_filter :rel100_mode
  relationship_filter :rx_inband_dtmf_filtering_mode
  relationship_filter :tx_inband_dtmf_filtering_mode
  relationship_filter :network_protocol_priority
  relationship_filter :media_encryption_mode

  ransack_filter :host, type: :string
  ransack_filter :port, type: :number
  ransack_filter :src_rewrite_rule, type: :string
  ransack_filter :dst_rewrite_rule, type: :string
  ransack_filter :acd_limit, type: :number
  ransack_filter :asr_limit, type: :number
  ransack_filter :enabled, type: :boolean
  ransack_filter :name, type: :string
  ransack_filter :auth_enabled, type: :boolean
  ransack_filter :auth_user, type: :string
  ransack_filter :auth_password, type: :string
  ransack_filter :term_outbound_proxy, type: :string
  ransack_filter :term_next_hop_for_replies, type: :boolean
  ransack_filter :term_use_outbound_proxy, type: :boolean
  ransack_filter :allow_termination, type: :boolean
  ransack_filter :allow_origination, type: :boolean
  ransack_filter :proxy_media, type: :boolean
  ransack_filter :sst_enabled, type: :boolean
  ransack_filter :sst_minimum_timer, type: :number
  ransack_filter :sst_maximum_timer, type: :number
  ransack_filter :sst_accept501, type: :boolean
  ransack_filter :sst_session_expires, type: :number
  ransack_filter :term_force_outbound_proxy, type: :boolean
  ransack_filter :locked, type: :boolean
  ransack_filter :codecs_payload_order, type: :string
  ransack_filter :codecs_prefer_transcoding_for, type: :string
  ransack_filter :src_rewrite_result, type: :string
  ransack_filter :dst_rewrite_result, type: :string
  ransack_filter :termination_capacity, type: :number
  ransack_filter :term_next_hop, type: :string
  ransack_filter :orig_next_hop, type: :string
  # Disabled because there is no support for arrays in ransack_filter
  # ransack_filter :orig_append_headers_req, type: :array_of_strings
  # ransack_filter :orig_append_headers_reply, type: :array_of_strings
  # ransack_filter :term_append_headers_req, type: :array_of_strings
  ransack_filter :dialog_nat_handling, type: :boolean
  ransack_filter :orig_force_outbound_proxy, type: :boolean
  ransack_filter :orig_use_outbound_proxy, type: :boolean
  ransack_filter :orig_outbound_proxy, type: :string
  ransack_filter :prefer_existing_codecs, type: :boolean
  ransack_filter :force_symmetric_rtp, type: :boolean
  ransack_filter :sdp_alines_filter_list, type: :string
  ransack_filter :diversion_domain, type: :string
  ransack_filter :diversion_rewrite_rule, type: :string
  ransack_filter :diversion_rewrite_result, type: :string
  ransack_filter :src_name_rewrite_rule, type: :string
  ransack_filter :src_name_rewrite_result, type: :string
  ransack_filter :priority, type: :number
  ransack_filter :single_codec_in_200ok, type: :boolean
  ransack_filter :ringing_timeout, type: :number
  ransack_filter :symmetric_rtp_nonstop, type: :boolean
  ransack_filter :resolve_ruri, type: :boolean
  ransack_filter :force_dtmf_relay, type: :boolean
  ransack_filter :relay_options, type: :boolean
  ransack_filter :rtp_ping, type: :boolean
  ransack_filter :filter_noaudio_streams, type: :boolean
  ransack_filter :relay_reinvite, type: :boolean
  ransack_filter :auth_from_user, type: :string
  ransack_filter :auth_from_domain, type: :string
  ransack_filter :relay_hold, type: :boolean
  ransack_filter :rtp_timeout, type: :number
  ransack_filter :relay_prack, type: :boolean
  ransack_filter :rtp_relay_timestamp_aligning, type: :boolean
  ransack_filter :allow_1xx_without_to_tag, type: :boolean
  ransack_filter :dns_srv_failover_timer, type: :number
  ransack_filter :rtp_force_relay_cn, type: :boolean
  ransack_filter :relay_update, type: :boolean
  ransack_filter :suppress_early_media, type: :boolean
  ransack_filter :send_lnp_information, type: :boolean
  ransack_filter :short_calls_limit, type: :number
  ransack_filter :origination_capacity, type: :number
  ransack_filter :force_one_way_early_media, type: :boolean
  ransack_filter :transit_headers_from_origination, type: :string
  ransack_filter :transit_headers_from_termination, type: :string
  ransack_filter :external_id, type: :number
  ransack_filter :fake_180_timer, type: :number
  ransack_filter :sip_interface_name, type: :string
  ransack_filter :rtp_interface_name, type: :string
  ransack_filter :rel100_mode_id, type: :number
  ransack_filter :is_shared, type: :boolean
  ransack_filter :max_30x_redirects, type: :number
  ransack_filter :max_transfers, type: :number
  ransack_filter :incoming_auth_username, type: :string
  ransack_filter :incoming_auth_password, type: :string
  ransack_filter :preserve_anonymous_from_domain, type: :boolean
  ransack_filter :registered_aor_mode_id, type: :number
  ransack_filter :weight, type: :number
  ransack_filter :force_cancel_routeset, type: :boolean
  ransack_filter :sip_schema_id, type: :number

  def self.updatable_fields(_context)
    %i[
      name
      enabled
      priority
      weight
      acd_limit
      asr_limit
      contractor
      sdp_alines_filter_type
      codec_group
      sdp_c_location
      sensor_level
      dtmf_receive_mode
      dtmf_send_mode
      rx_inband_dtmf_filtering_mode
      tx_inband_dtmf_filtering_mode
      rel100_mode
      session_refresh_method
      transport_protocol
      term_proxy_transport_protocol
      orig_proxy_transport_protocol
      gateway_group
      pop
      allow_origination
      allow_termination
      sst_enabled
      sensor
      host
      port
      resolve_ruri
      diversion_send_mode
      diversion_domain
      diversion_rewrite_rule
      diversion_rewrite_result
      src_name_rewrite_rule
      src_name_rewrite_result
      src_rewrite_rule
      src_rewrite_result
      dst_rewrite_rule
      dst_rewrite_result
      auth_enabled
      auth_user
      auth_password
      auth_from_user
      auth_from_domain
      term_use_outbound_proxy
      term_force_outbound_proxy
      term_outbound_proxy
      term_next_hop_for_replies
      term_next_hop
      term_disconnect_policy
      term_append_headers_req
      orig_append_headers_req
      orig_append_headers_reply
      sdp_alines_filter_list
      ringing_timeout
      relay_options
      relay_reinvite
      relay_hold
      relay_prack
      relay_update
      suppress_early_media
      fake_180_timer
      transit_headers_from_origination
      transit_headers_from_termination
      sip_interface_name
      allow_1xx_without_to_tag
      sip_timer_b
      dns_srv_failover_timer
      proxy_media
      single_codec_in_200ok
      force_symmetric_rtp
      symmetric_rtp_nonstop
      force_dtmf_relay
      rtp_ping
      rtp_timeout
      filter_noaudio_streams
      rtp_relay_timestamp_aligning
      rtp_force_relay_cn
      network_protocol_priority
      media_encryption_mode
      sip_schema_id
      preserve_anonymous_from_domain
      registered_aor_mode_id
      origination_capacity
      termination_capacity
      incoming_auth_username
      incoming_auth_password
      force_cancel_routeset
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
