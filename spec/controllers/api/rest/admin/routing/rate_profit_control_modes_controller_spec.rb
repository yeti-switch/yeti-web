# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::RateProfitControlModesController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :rate_profit_control_mode }

    it_behaves_like :jsonapi_filters_by_string_field, :name
  end
end
