# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::NodesController, type: :request do
  include_context :json_api_admin_helpers, type: :nodes

  describe 'GET /api/rest/admin/nodes' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:nodes) do
      FactoryBot.create_list(:node, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        nodes.map { |r| r.id.to_s }
      end
    end
  end
end
