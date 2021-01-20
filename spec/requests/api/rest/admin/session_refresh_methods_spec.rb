# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::SessionRefreshMethodsController, type: :request do
  include_context :json_api_admin_helpers, type: :'session-refresh-methods'

  describe 'GET /api/rest/admin/session-refresh-methods' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:session_refresh_methods) do
      SessionRefreshMethod.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        session_refresh_methods.map { |r| r.id.to_s }
      end
    end
  end
end
