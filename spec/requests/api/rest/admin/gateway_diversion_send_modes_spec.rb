# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::GatewayDiversionSendModesController, type: :request do
  include_context :json_api_admin_helpers, type: :'gateway-diversion-send-modes'

  describe 'GET /api/rest/admin/gateway-diversion-send-modes' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:gateway_diversion_send_modes) do
      Equipment::GatewayDiversionSendMode.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        gateway_diversion_send_modes.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end
end
