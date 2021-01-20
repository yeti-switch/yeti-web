# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::System::NetworksController, type: :request do
  include_context :json_api_admin_helpers, type: :networks, prefix: 'system'

  describe 'GET /api/rest/admin/system/networks' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
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
  end
end
