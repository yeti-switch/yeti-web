# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::SortingsController, type: :request do
  include_context :json_api_admin_helpers, type: :sortings

  describe 'GET /api/rest/admin/sortings' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:sortings) do
      Sorting.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        sortings.map { |r| r.id.to_s }
      end
    end
  end
end
