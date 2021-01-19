# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::AreasController, type: :request do
  include_context :json_api_admin_helpers, type: :areas, prefix: '/api/rest/admin/routing'

  describe 'GET /api/rest/admin/equipment/areas' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:areas) do
      FactoryBot.create_list(:area, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        areas.map { |r| r.id.to_s }
      end
    end
  end
end
