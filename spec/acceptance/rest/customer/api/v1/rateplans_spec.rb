# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Rateplans', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  include_context :customer_v1_cookie_helpers
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'rateplans' }

  required_params = %i[name]

  let(:customers_auth) do
    create(:customers_auth, customer_id: customer.id)
  end

  let!(:rateplan) { customers_auth.rateplan.reload }

  get '/api/rest/customer/v1/rateplans' do
    jsonapi_filters Api::Rest::Customer::V1::RateplanResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/rateplans/:id' do
    let(:id) { rateplan.reload.uuid }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
