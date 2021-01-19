# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Equipment::GatewayNetworkProtocolPrioritiesController, type: :request do
  include_context :json_api_admin_helpers, type: :'gateway-network-protocol-priorities', prefix: 'equipment'

  describe 'GET /api/rest/admin/equipment/gateway-network-protocol-priorities' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:gateway_network_protocol_priorities) do
      Equipment::GatewayNetworkProtocolPriority.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        gateway_network_protocol_priorities.map { |r| r.id.to_s }
      end
    end
  end
end
