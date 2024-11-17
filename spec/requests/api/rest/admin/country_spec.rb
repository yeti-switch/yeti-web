# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CountriesController, type: :request do
  include_context :json_api_admin_helpers, type: :countries

  describe 'GET /api/rest/admin/countries' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    before do
      System::NetworkPrefix.delete_all
      System::Country.delete_all
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

    it_behaves_like :json_api_admin_check_authorization
  end
end
