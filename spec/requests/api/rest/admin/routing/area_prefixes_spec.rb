# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::AreaPrefixesController, type: :request do
  include_context :json_api_admin_helpers, type: :'area-prefixes', prefix: 'routing'

  describe 'GET /api/rest/admin/equipment/area-prefixes' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:area_prefixes) do
      FactoryBot.create_list(:area_prefix, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        area_prefixes.map { |r| r.id.to_s }
      end
    end
  end
end
