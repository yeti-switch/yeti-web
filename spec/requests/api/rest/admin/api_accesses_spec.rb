# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::ApiAccessesController, type: :request do
  include_context :json_api_admin_helpers, type: :'api-accesses'

  describe 'GET /api/rest/admin/api-accesses' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:api_accesses) do
      FactoryBot.create_list(:api_access, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        api_accesses.map { |r| r.id.to_s }
      end
    end
  end
end
