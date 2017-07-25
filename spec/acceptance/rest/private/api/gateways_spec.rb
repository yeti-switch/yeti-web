require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Gateways' do
  header 'Accept', 'application/json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  required_params = [
    :name, :enabled, :priority, :acd_limit, :asr_limit,
    :contractor_id, :sdp_alines_filter_type_id, :codec_group_id, :sdp_c_location_id, :sensor_level_id,
    :dtmf_receive_mode_id, :dtmf_send_mode_id, :rel100_mode_id, :session_refresh_method_id, :transport_protocol_id,
    :term_proxy_transport_protocol_id, :orig_proxy_transport_protocol_id
  ]

  optional_params = [
    :gateway_group_id, :pop_id, :allow_origination, :allow_termination, :sst_enabled,
    :sensor_id, :host, :port, :resolve_ruri, :diversion_policy_id, :diversion_rewrite_rule,
    :diversion_rewrite_result, :src_name_rewrite_rule, :src_name_rewrite_result, :src_rewrite_rule,
    :src_rewrite_result, :dst_rewrite_rule, :dst_rewrite_result, :auth_enabled, :auth_user, :auth_password,
    :auth_from_user, :auth_from_domain, :term_use_outbound_proxy, :term_force_outbound_proxy, :term_outbound_proxy,
    :term_next_hop_for_replies, :term_next_hop, :term_disconnect_policy_id, :term_append_headers_req,
    :sdp_alines_filter_list, :ringing_timeout, :relay_options, :relay_reinvite, :relay_hold, :relay_prack,
    :relay_update, :suppress_early_media, :fake_180_timer, :transit_headers_from_origination,
    :transit_headers_from_termination, :sip_interface_name, :allow_1xx_without_to_tag, :sip_timer_b,
    :dns_srv_failover_timer, :anonymize_sdp, :proxy_media, :single_codec_in_200ok, :transparent_seqno,
    :transparent_ssrc, :force_symmetric_rtp, :symmetric_rtp_nonstop, :symmetric_rtp_ignore_rtcp, :force_dtmf_relay,
    :rtp_ping, :rtp_timeout, :filter_noaudio_streams, :rtp_relay_timestamp_aligning, :rtp_force_relay_cn
  ]

  get '/api/rest/private/gateways' do
    before { create_list(:gateway, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/gateways/:id' do
    let(:id) { create(:gateway).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/gateways' do
    required_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :gateway, required: true
    end

    optional_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :gateway
    end

    let(:name) { 'name' }
    let(:enabled) { true }
    let(:priority) { 1 }
    let(:acd_limit) { 0.0 }
    let(:asr_limit) { 0.0 }
    let(:sdp_alines_filter_type_id) { 0 }
    let(:session_refresh_method_id) { 1 }
    let(:sdp_c_location_id) { 2 }
    let(:sensor_level_id) { 1 }
    let(:dtmf_receive_mode_id) { 1 }
    let(:dtmf_send_mode_id) { 1 }
    let(:rel100_mode_id) { 1 }
    let(:transport_protocol_id) { 1 }
    let(:term_proxy_transport_protocol_id) { 1 }
    let(:orig_proxy_transport_protocol_id) { 1 }
    let(:contractor_id) { create(:contractor, vendor: true).id }
    let(:codec_group_id) { create(:codec_group).id }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/gateways/:id' do
    required_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :gateway, required: true
    end

    optional_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :gateway
    end

    let(:id) { create(:gateway).id }
    let(:name) { 'name' }
    let(:acd_limit) { 1.0 }

    example_request 'update values' do
      expect(status).to eq(204)
    end
  end

  delete '/api/rest/private/gateways/:id' do
    let(:id) { create(:gateway).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
