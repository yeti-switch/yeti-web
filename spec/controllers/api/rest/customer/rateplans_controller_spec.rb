# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Customer::V1::RateplansController, type: :controller do
  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }
  let(:customers_auth) { create :customers_auth, customer: customer }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:rateplans) { create_list :rateplan, 2, customers_auths: [customers_auth] }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(rateplans.size) }
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :rateplan }
    let(:factory_attrs) { { customers_auths: [customers_auth] } }

    it_behaves_like :jsonapi_filters_by_string_field, :name
  end
end
