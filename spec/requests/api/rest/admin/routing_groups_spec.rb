# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::RoutingGroupsController, type: :request do
  include_context :json_api_admin_helpers, type: :'routing-groups'

  describe 'GET /api/rest/admin/routing-groups' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    before { FactoryBot.create_list(:routing_group, 2) }
    let!(:routing_groups) do
      RoutingGroup.all.to_a
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        routing_groups.map { |r| r.id.to_s }
      end
    end
  end
end
