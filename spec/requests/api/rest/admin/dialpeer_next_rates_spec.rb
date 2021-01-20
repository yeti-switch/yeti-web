# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::DialpeerNextRatesController, type: :request do
  include_context :json_api_admin_helpers, type: :'dialpeer-next-rates'

  describe 'GET /api/rest/admin/dialpeer-next-rates' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:dialpeer_next_rates) do
      FactoryBot.create_list(:dialpeer_next_rate, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        dialpeer_next_rates.map { |r| r.id.to_s }
      end
    end
  end
end
