# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::DialpeerNextRatesController do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    subject { get :index, params: { dialpeer_id: 1, format: :json } }

    it 'should return status 200' do
      subject
      expect(response.status).to eq 200
    end
  end

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :dialpeer_next_rate }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filters_by_number_field, :next_rate
    it_behaves_like :jsonapi_filters_by_number_field, :initial_rate
    it_behaves_like :jsonapi_filters_by_number_field, :initial_interval
    it_behaves_like :jsonapi_filters_by_number_field, :next_interval
    it_behaves_like :jsonapi_filters_by_number_field, :connect_fee
    it_behaves_like :jsonapi_filters_by_boolean_field, :applied
    it_behaves_like :jsonapi_filters_by_number_field, :external_id
  end
end
