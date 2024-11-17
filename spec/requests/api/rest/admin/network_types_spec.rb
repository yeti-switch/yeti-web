# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::NetworkTypesController, type: :request do
  include_context :json_api_admin_helpers, type: :'network-types'

  describe 'GET /api/rest/admin/network-types' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    before { FactoryBot.create_list(:network_type, 2) }
    let!(:network_types) do
      System::NetworkType.all.to_a
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        network_types.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end
end
