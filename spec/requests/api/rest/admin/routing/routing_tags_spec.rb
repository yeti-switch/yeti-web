# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::RoutingTagsController, type: :request do
  include_context :json_api_admin_helpers, type: :'routing-tags', prefix: '/api/rest/admin/routing'

  describe 'GET /api/rest/admin/equipment/routing-tags' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:routing_tags) do
      FactoryBot.create_list(:routing_tag, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        routing_tags.map { |r| r.id.to_s }
      end
    end
  end
end
