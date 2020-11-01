# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Rates', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }
  let(:type) { 'rates' }

  required_params = %i[name]

  let(:customers_auth) do
    create(:customers_auth, customer_id: customer.id)
  end

  let(:rateplan) { customers_auth.rateplan.reload }
  let(:rate_group) { create(:rate_group, rateplans: [rateplan])}
  let!(:rate) { create(:rate, rate_group: rate_group) }

  get '/api/rest/customer/v1/rates' do
    jsonapi_filters Api::Rest::Customer::V1::RateResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/rates/:id' do
    let(:id) { rate.reload.uuid }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
