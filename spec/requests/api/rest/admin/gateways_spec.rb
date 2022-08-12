# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::GatewaysController, type: :request do
  include_context :json_api_admin_helpers, type: :gateways

  gateway_relationship_names = %i[
    contractor
    session-refresh-method
    sdp-alines-filter-type
    term-disconnect-policy
    gateway-group
    diversion-send-mode
    pop
    codec-group
    sdp-c-location
    sensor
    sensor-level
    dtmf-receive-mode
    dtmf-send-mode
    transport-protocol
    term-proxy-transport-protocol
    orig-proxy-transport-protocol
    rel100-mode
    rx-inband-dtmf-filtering-mode
    tx-inband-dtmf-filtering-mode
    network-protocol-priority
    media-encryption-mode
    sip-schema
  ]

  describe 'GET /api/rest/admin/gateways' do
    subject do
      get json_api_request_path, params: request_params, headers: json_api_request_headers
    end

    let!(:gateways) do
      FactoryBot.create_list(:gateway, 2) # only Contact with contractor
    end
    let(:request_params) { nil }

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        gateways.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization

    context 'with filter by contractor.id' do
      let!(:contractor) { create(:vendor) }
      let!(:other_contractor) { create(:vendor) }
      let!(:gateways) { create_list(:gateway, 3, contractor: contractor) }
      before { create(:gateway, contractor: other_contractor) }

      let(:request_params) do
        { filter: { 'contractor.id': contractor.id } }
      end

      it 'returns filtered gateways by contractor.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by session_refresh_method.id' do
      let!(:session_refresh_method) { SessionRefreshMethod.first }
      let!(:other_session_refresh_methods) { SessionRefreshMethod.second }
      let!(:gateways) { create_list(:gateway, 3, session_refresh_method: session_refresh_method) }
      before { create(:gateway, session_refresh_method: other_session_refresh_methods) }

      let(:request_params) do
        { filter: { 'session_refresh_method.id': session_refresh_method.id } }
      end

      it 'returns filtered gateways by session_refresh_method.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by sdp_alines_filter_type.id' do
      let!(:sdp_alines_filter_type) { FilterType.first }
      let!(:other_sdp_alines_filter_type) { FilterType.second }
      let!(:gateways) { create_list(:gateway, 3, sdp_alines_filter_type: sdp_alines_filter_type) }
      before { create(:gateway, sdp_alines_filter_type: other_sdp_alines_filter_type) }

      let(:request_params) do
        { filter: { 'sdp_alines_filter_type.id': sdp_alines_filter_type.id } }
      end

      it 'returns filtered gateways by sdp_alines_filter_type.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by term_disconnect_policy.id' do
      let!(:disconnect_policy) { create(:disconnect_policy) }
      let!(:other_disconnect_policy) { create(:disconnect_policy) }
      let!(:gateways) { create_list(:gateway, 3, term_disconnect_policy: disconnect_policy) }
      before { create(:gateway, term_disconnect_policy: other_disconnect_policy) }

      let(:request_params) do
        { filter: { 'term_disconnect_policy.id': disconnect_policy.id } }
      end

      it 'returns filtered gateways by term_disconnect_policy.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by gateway_group.id' do
      let!(:gateway_group) { create(:gateway_group) }
      let!(:other_gateway_group) { create(:gateway_group) }
      let!(:gateways) { create_list(:gateway, 3, gateway_group: gateway_group, contractor: gateway_group.vendor) }
      before { create(:gateway, gateway_group: other_gateway_group, contractor: other_gateway_group.vendor) }

      let(:request_params) do
        { filter: { 'gateway_group.id': gateway_group.id } }
      end

      it 'returns filtered gateways by gateway_group.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by diversion_send_mode.id' do
      let!(:diversion_send_mode) { Equipment::GatewayDiversionSendMode.first }
      let!(:other_diversion_send_mode) { Equipment::GatewayDiversionSendMode.create!(id: 2, name: 'Test') }
      let!(:gateways) { create_list(:gateway, 3, diversion_send_mode: diversion_send_mode) }
      before { create(:gateway, diversion_send_mode: other_diversion_send_mode) }

      let(:request_params) do
        { filter: { 'diversion_send_mode.id': diversion_send_mode.id } }
      end

      it 'returns filtered gateways by diversion_send_mode.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by pop.id' do
      let!(:pop) { create(:pop) }
      let!(:other_pop) { create(:pop) }
      let!(:gateways) { create_list(:gateway, 3, pop: pop) }
      before { create(:gateway, pop: other_pop) }

      let(:request_params) do
        { filter: { 'pop.id': pop.id } }
      end

      it 'returns filtered gateways by pop.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by codec_group.id' do
      let!(:codec_group) { create(:codec_group) }
      let!(:other_codec_group) { create(:codec_group) }
      let!(:gateways) { create_list(:gateway, 3, codec_group: codec_group) }
      before { create(:gateway, codec_group: other_codec_group) }

      let(:request_params) do
        { filter: { 'codec_group.id': codec_group.id } }
      end

      it 'returns filtered gateways by codec_group.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by sdp_c_location.id' do
      let!(:sdp_c_location) { SdpCLocation.first }
      let!(:other_sdp_c_location) { SdpCLocation.second }
      let!(:gateways) { create_list(:gateway, 3, sdp_c_location: sdp_c_location) }
      before { create(:gateway, sdp_c_location: other_sdp_c_location) }

      let(:request_params) do
        { filter: { 'sdp_c_location.id': sdp_c_location.id } }
      end

      it 'returns filtered gateways by codec_group.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by sensor.id' do
      let!(:sensor) { create(:sensor) }
      let!(:other_sensor) { create(:sensor) }
      let!(:gateways) { create_list(:gateway, 3, sensor: sensor) }
      before { create(:gateway, sensor: other_sensor) }

      let(:request_params) do
        { filter: { 'sensor.id': sensor.id } }
      end

      it 'returns filtered gateways by sensor.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by sensor_level.id' do
      let!(:sensor_level) { System::SensorLevel.first }
      let!(:other_sensor_level) { System::SensorLevel.second }
      let!(:gateways) { create_list(:gateway, 3, sensor_level: sensor_level) }
      before { create(:gateway, sensor_level: other_sensor_level) }

      let(:request_params) do
        { filter: { 'sensor_level.id': sensor_level.id } }
      end

      it 'returns filtered gateways by sensor_level.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by dtmf_receive_mode.id' do
      let!(:dtmf_receive_mode) { System::DtmfReceiveMode.first }
      let!(:other_dtmf_receive_mode) { System::DtmfReceiveMode.second }
      let!(:gateways) { create_list(:gateway, 3, dtmf_receive_mode: dtmf_receive_mode) }
      before { create(:gateway, dtmf_receive_mode: other_dtmf_receive_mode) }

      let(:request_params) do
        { filter: { 'dtmf_receive_mode.id': dtmf_receive_mode.id } }
      end

      it 'returns filtered gateways by dtmf_receive_mode.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by dtmf_receive_mode.id' do
      let!(:dtmf_receive_mode) { System::DtmfReceiveMode.first }
      let!(:other_dtmf_receive_mode) { System::DtmfReceiveMode.second }
      let!(:gateways) { create_list(:gateway, 3, dtmf_receive_mode: dtmf_receive_mode) }
      before { create(:gateway, dtmf_receive_mode: other_dtmf_receive_mode) }

      let(:request_params) do
        { filter: { 'dtmf_receive_mode.id': dtmf_receive_mode.id } }
      end

      it 'returns filtered gateways by dtmf_receive_mode.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by dtmf_send_mode.id' do
      let!(:dtmf_send_mode) { System::DtmfSendMode.first }
      let!(:other_dtmf_send_mode) { System::DtmfSendMode.second }
      let!(:gateways) { create_list(:gateway, 3, dtmf_send_mode: dtmf_send_mode) }
      before { create(:gateway, dtmf_send_mode: other_dtmf_send_mode) }

      let(:request_params) do
        { filter: { 'dtmf_send_mode.id': dtmf_send_mode.id } }
      end

      it 'returns filtered gateways by dtmf_send_mode.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by transport_protocol.id' do
      let!(:transport_protocol) { Equipment::TransportProtocol.first }
      let!(:other_transport_protocol) { Equipment::TransportProtocol.second }
      let!(:gateways) { create_list(:gateway, 3, transport_protocol: transport_protocol) }
      before { create(:gateway, transport_protocol: other_transport_protocol) }

      let(:request_params) do
        { filter: { 'transport_protocol.id': transport_protocol.id } }
      end

      it 'returns filtered gateways by transport_protocol.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by term_proxy_transport_protocol.id' do
      let!(:transport_protocol) { Equipment::TransportProtocol.first }
      let!(:other_transport_protocol) { Equipment::TransportProtocol.second }
      let!(:gateways) { create_list(:gateway, 3, term_proxy_transport_protocol: transport_protocol) }
      before { create(:gateway, term_proxy_transport_protocol: other_transport_protocol) }

      let(:request_params) do
        { filter: { 'term_proxy_transport_protocol.id': transport_protocol.id } }
      end

      it 'returns filtered gateways by term_proxy_transport_protocol.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by orig_proxy_transport_protocol.id' do
      let!(:transport_protocol) { Equipment::TransportProtocol.first }
      let!(:other_transport_protocol) { Equipment::TransportProtocol.second }
      let!(:gateways) { create_list(:gateway, 3, orig_proxy_transport_protocol: transport_protocol) }
      before { create(:gateway, orig_proxy_transport_protocol: other_transport_protocol) }

      let(:request_params) do
        { filter: { 'orig_proxy_transport_protocol.id': transport_protocol.id } }
      end

      it 'returns filtered gateways by orig_proxy_transport_protocol.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by rel100_mode.id' do
      let!(:rel100_mode) { Equipment::GatewayRel100Mode.first }
      let!(:other_rel100_mode) { Equipment::GatewayRel100Mode.second }
      let!(:gateways) { create_list(:gateway, 3, rel100_mode: rel100_mode) }
      before { create(:gateway, rel100_mode: other_rel100_mode) }

      let(:request_params) do
        { filter: { 'rel100_mode.id': rel100_mode.id } }
      end

      it 'returns filtered gateways by rel100_mode.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by rx_inband_dtmf_filtering_mode.id' do
      let!(:rx_inband_dtmf_filtering_mode) { Equipment::GatewayInbandDtmfFilteringMode.first }
      let!(:other_rx_inband_dtmf_filtering_mode) { Equipment::GatewayInbandDtmfFilteringMode.second }
      let!(:gateways) { create_list(:gateway, 3, rx_inband_dtmf_filtering_mode: rx_inband_dtmf_filtering_mode) }
      before { create(:gateway, rx_inband_dtmf_filtering_mode: other_rx_inband_dtmf_filtering_mode) }

      let(:request_params) do
        { filter: { 'rx_inband_dtmf_filtering_mode.id': rx_inband_dtmf_filtering_mode.id } }
      end

      it 'returns filtered gateways by rx_inband_dtmf_filtering_mode.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by tx_inband_dtmf_filtering_mode.id' do
      let!(:tx_inband_dtmf_filtering_mode) { Equipment::GatewayInbandDtmfFilteringMode.first }
      let!(:other_tx_inband_dtmf_filtering_mode) { Equipment::GatewayInbandDtmfFilteringMode.second }
      let!(:gateways) { create_list(:gateway, 3, tx_inband_dtmf_filtering_mode: tx_inband_dtmf_filtering_mode) }
      before { create(:gateway, tx_inband_dtmf_filtering_mode: other_tx_inband_dtmf_filtering_mode) }

      let(:request_params) do
        { filter: { 'tx_inband_dtmf_filtering_mode.id': tx_inband_dtmf_filtering_mode.id } }
      end

      it 'returns filtered gateways by tx_inband_dtmf_filtering_mode.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by network_protocol_priority.id' do
      let!(:network_protocol_priority) { Equipment::GatewayNetworkProtocolPriority.first }
      let!(:other_network_protocol_priority) { Equipment::GatewayNetworkProtocolPriority.second }
      let!(:gateways) { create_list(:gateway, 3, network_protocol_priority: network_protocol_priority) }
      before { create(:gateway, network_protocol_priority: other_network_protocol_priority) }

      let(:request_params) do
        { filter: { 'network_protocol_priority.id': network_protocol_priority.id } }
      end

      it 'returns filtered gateways by network_protocol_priority.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by media_encryption_mode.id' do
      let!(:media_encryption_mode) { Equipment::GatewayMediaEncryptionMode.first }
      let!(:other_media_encryption_mode) { Equipment::GatewayMediaEncryptionMode.second }
      let!(:gateways) { create_list(:gateway, 3, media_encryption_mode: media_encryption_mode) }
      before { create(:gateway, media_encryption_mode: other_media_encryption_mode) }

      let(:request_params) do
        { filter: { 'media_encryption_mode.id': media_encryption_mode.id } }
      end

      it 'returns filtered gateways by media_encryption_mode.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end

    context 'with filter by sip_schema.id' do
      let!(:sip_schema) { System::SipSchema.first }
      let!(:other_sip_schema) { System::SipSchema.second }
      let!(:gateways) { create_list(:gateway, 3, sip_schema: sip_schema) }
      before { create(:gateway, sip_schema: other_sip_schema) }

      let(:request_params) do
        { filter: { 'sip_schema.id': sip_schema.id } }
      end

      it 'returns filtered gateways by sip_schema.id' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |r| r[:id] }
        expect(actual_ids).to match_array gateways.map(&:id).map(&:to_s)
      end
    end
  end

  describe 'GET /api/rest/admin/gateways/{id}' do
    subject do
      get json_api_request_path, params: request_params, headers: json_api_request_headers
    end

    let!(:gateway_response_attributes) do
      {
        name: gateway.name,
        enabled: gateway.enabled,
        priority: gateway.priority,
        weight: gateway.weight,
        'acd-limit': gateway.acd_limit,
        'asr-limit': gateway.asr_limit,
        'allow-origination': gateway.allow_origination,
        'allow-termination': gateway.allow_termination,
        'sst-enabled': gateway.sst_enabled,
        host: gateway.host,
        port: gateway.port,
        'resolve-ruri': gateway.resolve_ruri,
        'diversion-domain': gateway.diversion_domain,
        'diversion-rewrite-rule': gateway.diversion_rewrite_rule,
        'diversion-rewrite-result': gateway.diversion_rewrite_result,
        'src-name-rewrite-rule': gateway.src_name_rewrite_rule,
        'src-name-rewrite-result': gateway.src_name_rewrite_result,
        'src-rewrite-rule': gateway.src_rewrite_rule,
        'src-rewrite-result': gateway.src_rewrite_result,
        'dst-rewrite-rule': gateway.dst_rewrite_rule,
        'dst-rewrite-result': gateway.dst_rewrite_result,
        'auth-enabled': gateway.auth_enabled,
        'auth-user': gateway.auth_user,
        'auth-password': gateway.auth_password,
        'auth-from-user': gateway.auth_from_user,
        'auth-from-domain': gateway.auth_from_domain,
        'term-use-outbound-proxy': gateway.term_use_outbound_proxy,
        'termination-capacity': gateway.termination_capacity,
        'term-force-outbound-proxy': gateway.term_force_outbound_proxy,
        'term-outbound-proxy': gateway.term_outbound_proxy,
        'term-next-hop-for-replies': gateway.term_next_hop_for_replies,
        'term-next-hop': gateway.term_next_hop,
        'term-append-headers-req': gateway.term_append_headers_req,
        'sdp-alines-filter-list': gateway.sdp_alines_filter_list,
        'ringing-timeout': gateway.ringing_timeout,
        'relay-options': gateway.relay_options,
        'relay-reinvite': gateway.relay_reinvite,
        'relay-hold': gateway.relay_hold,
        'relay-prack': gateway.relay_prack,
        'relay-update': gateway.relay_update,
        'suppress-early-media': gateway.suppress_early_media,
        'fake-180-timer': gateway.fake_180_timer,
        'transit-headers-from-origination': gateway.transit_headers_from_origination,
        'transit-headers-from-termination': gateway.transit_headers_from_termination,
        'sip-interface-name': gateway.sip_interface_name,
        'allow-1xx-without-to-tag': gateway.allow_1xx_without_to_tag,
        'sip-timer-b': gateway.sip_timer_b,
        'dns-srv-failover-timer': gateway.dns_srv_failover_timer,
        'proxy-media': gateway.proxy_media,
        'origination-capacity': gateway.origination_capacity,
        'preserve-anonymous-from-domain': gateway.preserve_anonymous_from_domain,
        'single-codec-in-200ok': gateway.single_codec_in_200ok,
        'use-registered-aor': gateway.use_registered_aor,
        'force-symmetric-rtp': gateway.force_symmetric_rtp,
        'symmetric-rtp-nonstop': gateway.symmetric_rtp_nonstop,
        'symmetric-rtp-ignore-rtcp': gateway.symmetric_rtp_ignore_rtcp,
        'force-dtmf-relay': gateway.force_dtmf_relay,
        'rtp-ping': gateway.rtp_ping,
        'rtp-timeout': gateway.rtp_timeout,
        'filter-noaudio-streams': gateway.filter_noaudio_streams,
        'rtp-relay-timestamp-aligning': gateway.rtp_relay_timestamp_aligning,
        'rtp-force-relay-cn': gateway.rtp_force_relay_cn,
        'incoming-auth-username': gateway.incoming_auth_username,
        'incoming-auth-password': gateway.incoming_auth_password
      }
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:request_params) { nil }
    let(:record_id) { gateway.id.to_s }

    let!(:gateway) { FactoryBot.create(:gateway) }

    include_examples :returns_json_api_record, relationships: gateway_relationship_names do
      let(:json_api_record_id) { record_id }
      let(:json_api_record_attributes) { gateway_response_attributes }
    end

    it_behaves_like :json_api_admin_check_authorization
  end

  describe 'POST /api/rest/admin/gateways' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:contractor) { FactoryBot.create(:customer) }
    let(:session_refresh_method) { SessionRefreshMethod.first }
    let(:sdp_alines_filter_type) { FilterType.first }
    let(:codec_group) { FactoryBot.create(:codec_group) }
    let(:sdp_c_location) { SdpCLocation.first }
    let(:sensor_level) { System::SensorLevel.first }
    let(:dtmf_receive_mode) { System::DtmfReceiveMode.first }
    let(:dtmf_send_mode) { System::DtmfSendMode.first }
    let(:transport_protocol) { Equipment::TransportProtocol.first }
    let(:term_proxy_transport_protocol) { Equipment::TransportProtocol.first }
    let(:orig_proxy_transport_protocol) { Equipment::TransportProtocol.first }
    let(:rel100_mode) { Equipment::GatewayRel100Mode.first }
    let(:rx_inband_dtmf_filtering_mode) { Equipment::GatewayInbandDtmfFilteringMode.first }
    let(:tx_inband_dtmf_filtering_mode) { Equipment::GatewayInbandDtmfFilteringMode.first }
    let(:network_protocol_priority) { Equipment::GatewayNetworkProtocolPriority.first }
    let(:media_encryption_mode) { Equipment::GatewayMediaEncryptionMode.first }
    let(:sip_schema) { System::SipSchema.first }

    let(:json_api_request_attributes) do
      {
        name: 'Test name',
        enabled: false,
        priority: 100,
        weight: 100,
        'acd-limit': 0.0,
        'asr-limit': 0.0,
        host: 'test.example.com'
      }
    end

    let(:json_api_request_body) do
      {
        data: {
          type: json_api_resource_type,
          attributes: json_api_request_attributes,
          relationships: json_api_request_relationships
        }
      }
    end

    let(:json_api_request_relationships) do
      {
        contractor: { data: { id: contractor.id.to_s, type: 'contractors' } },
        'session-refresh-method': { data: { id: session_refresh_method.id.to_s, type: 'session-refresh-methods' } },
        'sdp-alines-filter-type': { data: { id: sdp_alines_filter_type.id.to_s, type: 'filter-types' } },
        'codec-group': { data: { id: codec_group.id.to_s, type: 'codec-groups' } },
        'sdp-c-location': { data: { id: sdp_c_location.id.to_s, type: 'sdp-c-locations' } },
        'sensor-level': { data: { id: sensor_level.id.to_s, type: 'sensor-levels' } },
        'dtmf-receive-mode': { data: { id: dtmf_receive_mode.id.to_s, type: 'dtmf-receive-modes' } },
        'dtmf-send-mode': { data: { id: dtmf_send_mode.id.to_s, type: 'dtmf-send-modes' } },
        'transport-protocol': { data: { id: transport_protocol.id.to_s, type: 'transport-protocols' } },
        'term-proxy-transport-protocol': { data: { id: term_proxy_transport_protocol.id.to_s, type: 'transport-protocols' } },
        'orig-proxy-transport-protocol': { data: { id: orig_proxy_transport_protocol.id.to_s, type: 'transport-protocols' } },
        'rel100-mode': { data: { id: rel100_mode.id.to_s, type: 'gateway-rel100-modes' } },
        'rx-inband-dtmf-filtering-mode': { data: { id: rx_inband_dtmf_filtering_mode.id.to_s, type: 'gateway-inband-dtmf-filtering-modes' } },
        'tx-inband-dtmf-filtering-mode': { data: { id: tx_inband_dtmf_filtering_mode.id.to_s, type: 'gateway-inband-dtmf-filtering-modes' } },
        'network-protocol-priority': { data: { id: network_protocol_priority.id.to_s, type: 'gateway-network-protocol-priorities' } },
        'media-encryption-mode': { data: { id: media_encryption_mode.id.to_s, type: 'gateway-media-encryption-modes' } },
        'sip-schema': { data: { id: sip_schema.id.to_s, type: 'sip-schemas' } }
      }
    end

    let(:last_gateway) { Gateway.last! }

    include_examples :returns_json_api_record, relationships: gateway_relationship_names, status: 201 do
      let(:json_api_record_id) { last_gateway.id.to_s }
      let(:json_api_record_attributes) do
        hash_including(json_api_request_attributes)
      end
    end

    it_behaves_like :json_api_admin_check_authorization, status: 201

    it 'creates gateway with correct attributes' do
      expect { subject }.to change { Gateway.count }.by(1)

      expect(last_gateway).to have_attributes(
                                  name: json_api_request_attributes[:name],
                                  enabled: json_api_request_attributes[:enabled],
                                  priority: json_api_request_attributes[:priority],
                                  weight: json_api_request_attributes[:weight],
                                  acd_limit: json_api_request_attributes[:'acd-limit'],
                                  asr_limit: json_api_request_attributes[:'asr-limit'],
                                  host: json_api_request_attributes[:host],
                                  contractor: contractor,
                                  session_refresh_method: session_refresh_method,
                                  sdp_alines_filter_type: sdp_alines_filter_type,
                                  codec_group: codec_group,
                                  sdp_c_location: sdp_c_location,
                                  sensor_level: sensor_level,
                                  dtmf_receive_mode: dtmf_receive_mode,
                                  dtmf_send_mode: dtmf_send_mode,
                                  transport_protocol: transport_protocol,
                                  term_proxy_transport_protocol: term_proxy_transport_protocol,
                                  orig_proxy_transport_protocol: orig_proxy_transport_protocol,
                                  rel100_mode: rel100_mode,
                                  rx_inband_dtmf_filtering_mode: rx_inband_dtmf_filtering_mode,
                                  tx_inband_dtmf_filtering_mode: tx_inband_dtmf_filtering_mode,
                                  network_protocol_priority: network_protocol_priority,
                                  media_encryption_mode: media_encryption_mode,
                                  sip_schema: sip_schema
                                )
    end

    context 'with incoming-auth-username and incoming-auth-password' do
      let(:json_api_request_attributes) do
        super().merge 'incoming-auth-username': 'other_incoming_auth_username',
                      'incoming-auth-password': 'other_incoming_auth_password'
      end

      include_examples :returns_json_api_record, relationships: gateway_relationship_names, status: 201 do
        let(:json_api_record_id) { last_gateway.id.to_s }
        let(:json_api_record_attributes) do
          hash_including(json_api_request_attributes)
        end
      end

      it 'creates gateway with correct attributes' do
        expect { subject }.to change { Gateway.count }.by(1)

        expect(last_gateway).to have_attributes(
                                  incoming_auth_username: json_api_request_attributes[:'incoming-auth-username'],
                                  incoming_auth_password: json_api_request_attributes[:'incoming-auth-password']
                                )
      end
    end
  end

  describe 'PATCH /api/rest/admin/gateways/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { gateway.id.to_s }
    let(:json_api_request_body) do
      { data: { id: record_id, type: json_api_resource_type, attributes: json_api_request_attributes } }
    end

    let(:json_api_request_attributes) do
      {
        name: 'other name',
        enabled: false,
        priority: 100,
        weight: 100,
        'acd-limit': 0.1,
        'asr-limit': 0.1,
        host: 'other.test.example.com',
        'incoming-auth-username': 'other_incoming_auth_username',
        'incoming-auth-password': 'other_incoming_auth_password'
      }
    end

    let!(:gateway) { FactoryBot.create(:gateway) }

    include_examples :returns_json_api_record, relationships: gateway_relationship_names do
      let(:json_api_record_id) { gateway.id.to_s }
      let(:json_api_record_attributes) do
        hash_including(json_api_request_attributes)
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end
end
