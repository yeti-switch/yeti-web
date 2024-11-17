# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::NetworksController, type: :request do
  include_context :json_api_admin_helpers, type: :networks

  describe 'GET /api/rest/admin/networks' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    before do
      System::NetworkPrefix.delete_all
      System::Network.delete_all
    end
    let!(:networks) do
      FactoryBot.create_list(:network, 2, :uniq_name)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        networks.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end
end
