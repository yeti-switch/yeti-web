RSpec.describe Api::Rest::Admin::GatewaysController, type: :request do
  include_context :json_api_admin_helpers, type: :gateways

  describe 'GET /api/rest/admin/gateways' do
    subject do
      get json_api_request_path, params: request_params, headers: json_api_request_headers
    end

    let!(:gateways) do
      FactoryBot.create_list(:gateway, 2) # only Contact with contractor
    end
    let(:request_params) { nil }

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        gateways.map { |r| r.id.to_s }
      end
    end

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
      before { create(:gateway, gateway_group: other_gateway_group, contractor: other_gateway_group.vendor ) }

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

    context 'with filter by diversion_policy.id' do
      let!(:diversion_policy) { DiversionPolicy.first }
      let!(:other_diversion_policy) { DiversionPolicy.second }
      let!(:gateways) { create_list(:gateway, 3, diversion_policy: diversion_policy) }
      before { create(:gateway, diversion_policy: other_diversion_policy ) }

      let(:request_params) do
        { filter: { 'diversion_policy.id': diversion_policy.id } }
      end

      it 'returns filtered gateways by diversion_policy.id' do
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
end