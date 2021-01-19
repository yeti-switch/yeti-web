# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Equipment::TransportProtocolsController, type: :request do
  include_context :json_api_admin_helpers, type: :'transport-protocols', prefix: '/api/rest/admin/equipment'

  describe 'GET /api/rest/admin/equipment/transport-protocols' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:transport_protocols) do
      Equipment::TransportProtocol.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        transport_protocols.map { |r| r.id.to_s }
      end
    end
  end
end
