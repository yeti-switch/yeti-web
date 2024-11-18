# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::DestinationNextRatesController, type: :request do
  include_context :json_api_admin_helpers, type: :'destination-next-rates'

  describe 'GET /api/rest/admin/destination-next-rates' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:destination_next_rates) do
      FactoryBot.create_list(:destination_next_rate, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        destination_next_rates.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end
end
