# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::System::SensorsController, type: :request do
  include_context :json_api_admin_helpers, type: :sensors, prefix: 'system'

  describe 'GET /api/rest/admin/system/sensors' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:sensors) do
      FactoryBot.create_list(:sensor, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        sensors.map { |r| r.id.to_s }
      end
    end
  end
end
