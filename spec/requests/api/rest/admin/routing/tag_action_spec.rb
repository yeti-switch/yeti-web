# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::TagActionsController, type: :request do
  include_context :json_api_admin_helpers, type: :'tag-actions', prefix: '/api/rest/admin/routing'

  describe 'GET /api/rest/admin/equipment/tag-actions' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:tag_actions) do
      Routing::TagAction.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        tag_actions.map { |r| r.id.to_s }
      end
    end
  end
end
