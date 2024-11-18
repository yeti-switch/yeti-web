# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::GatewayMediaEncryptionModesController, type: :request do
  include_context :json_api_admin_helpers, type: :'gateway-media-encryption-modes'

  describe 'GET /api/rest/admin/gateway-media-encryption-modes' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:gateway_media_encryption_modes) do
      Equipment::GatewayMediaEncryptionMode.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        gateway_media_encryption_modes.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end
end
