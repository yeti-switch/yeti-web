# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Customer::V1::AccountsController, type: :controller do
  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:accounts) { create_list :account, 2, contractor: customer }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(accounts.size) }
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :account }
    let(:trait) { :with_max_balance }
    let(:factory_attrs) { { contractor: customer } }
    let(:pk) { :uuid }

    it_behaves_like :jsonapi_filters_by_string_field, :name
    it_behaves_like :jsonapi_filters_by_number_field, :balance
    it_behaves_like :jsonapi_filters_by_number_field, :min_balance
    it_behaves_like :jsonapi_filters_by_number_field, :max_balance
    it_behaves_like :jsonapi_filters_by_number_field, :balance_low_threshold
    it_behaves_like :jsonapi_filters_by_number_field, :balance_high_threshold
    it_behaves_like :jsonapi_filters_by_number_field, :destination_rate_limit
    it_behaves_like :jsonapi_filters_by_number_field, :max_call_duration
    it_behaves_like :jsonapi_filters_by_number_field, :external_id
    it_behaves_like :jsonapi_filters_by_uuid_field, :uuid
    it_behaves_like :jsonapi_filters_by_number_field, :origination_capacity
    it_behaves_like :jsonapi_filters_by_number_field, :termination_capacity
    it_behaves_like :jsonapi_filters_by_number_field, :total_capacity
  end
end
