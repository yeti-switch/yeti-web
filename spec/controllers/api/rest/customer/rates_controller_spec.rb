# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Customer::V1::RatesController, type: :controller do
  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }
  let(:customers_auth) { create :customers_auth, customer: customer }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token

    allow(Routing::Destination).to receive(:where_customer) { Routing::Destination.all }
  end

  describe 'GET index' do
    let!(:rates) { create_list :destination, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(rates.size) }
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :destination }
    let(:pk) { :uuid }

    it_behaves_like :jsonapi_filters_by_boolean_field, :enabled
    it_behaves_like :jsonapi_filters_by_string_field, :prefix
    it_behaves_like :jsonapi_filters_by_number_field, :next_rate
    it_behaves_like :jsonapi_filters_by_number_field, :connect_fee
    it_behaves_like :jsonapi_filters_by_number_field, :initial_interval
    it_behaves_like :jsonapi_filters_by_number_field, :next_interval
    it_behaves_like :jsonapi_filters_by_number_field, :dp_margin_fixed
    it_behaves_like :jsonapi_filters_by_number_field, :dp_margin_percent
    it_behaves_like :jsonapi_filters_by_number_field, :initial_rate
    it_behaves_like :jsonapi_filters_by_boolean_field, :reject_calls
    it_behaves_like :jsonapi_filters_by_boolean_field, :use_dp_intervals
    it_behaves_like :jsonapi_filters_by_datetime_field, :valid_from
    it_behaves_like :jsonapi_filters_by_datetime_field, :valid_till
    it_behaves_like :jsonapi_filters_by_number_field, :external_id
    it_behaves_like :jsonapi_filters_by_number_field, :asr_limit
    it_behaves_like :jsonapi_filters_by_number_field, :acd_limit
    it_behaves_like :jsonapi_filters_by_number_field, :short_calls_limit
    it_behaves_like :jsonapi_filters_by_boolean_field, :quality_alarm
    it_behaves_like :jsonapi_filters_by_uuid_field, :uuid
    it_behaves_like :jsonapi_filters_by_number_field, :dst_number_min_length
    it_behaves_like :jsonapi_filters_by_number_field, :dst_number_max_length
    it_behaves_like :jsonapi_filters_by_boolean_field, :reverse_billing
  end
end
