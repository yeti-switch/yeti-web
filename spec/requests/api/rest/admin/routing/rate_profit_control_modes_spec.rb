# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::RateProfitControlModesController, type: :request do
  include_context :json_api_admin_helpers, type: :'rate-profit-control-modes', prefix: 'routing'

  describe 'GET /api/rest/admin/equipment/rate-profit-control-modes' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:rate_profit_control_modes) do
      Routing::RateProfitControlMode.all
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        rate_profit_control_modes.map { |r| r.id.to_s }
      end
    end
  end
end
