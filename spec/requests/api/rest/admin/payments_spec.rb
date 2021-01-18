# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::PaymentsController, type: :request do
  include_context :json_api_admin_helpers, type: :payments

  describe 'GET /api/rest/admin/payments' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:payments) do
      FactoryBot.create_list(:payment, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        payments.map { |r| r.id.to_s }
      end
    end
  end
end
