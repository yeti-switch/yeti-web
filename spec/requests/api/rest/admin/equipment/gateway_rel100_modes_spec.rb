# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Equipment::GatewayRel100ModesController, type: :request do
  include_context :json_api_admin_helpers, type: :'gateway-rel100-modes', prefix: 'equipment'

  describe 'GET /api/rest/admin/equipment/gateway-rel100-modes' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:gateway_rel100_modes) do
      Equipment::GatewayRel100Mode.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        gateway_rel100_modes.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end
end
