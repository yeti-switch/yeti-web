# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::RoutingTagModesController, type: :request do
  include_context :json_api_admin_helpers, type: :'routing-tag-modes', prefix: '/api/rest/admin/routing'

  describe 'GET /api/rest/admin/equipment/routing-tag-modes' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:routing_tag_modes) do
      Routing::RoutingTagMode.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        routing_tag_modes.map { |r| r.id.to_s }
      end
    end
  end
end
