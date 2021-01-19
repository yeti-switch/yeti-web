# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::System::CountriesController, type: :request do
  include_context :json_api_admin_helpers, type: :countries, prefix: '/api/rest/admin/system'

  describe 'GET /api/rest/admin/system/countries' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:countries) do
      FactoryBot.create_list(:country, 2, :uniq_name)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        countries.map { |r| r.id.to_s }
      end
    end
  end
end
