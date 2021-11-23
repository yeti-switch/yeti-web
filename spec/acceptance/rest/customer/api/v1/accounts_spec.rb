# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Accounts', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  include_context :customer_v1_cookie_helpers
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'accounts' }

  required_params = %i[name balance origination-capacity min-balance max-balance]

  get '/api/rest/customer/v1/accounts' do
    jsonapi_filters Api::Rest::Customer::V1::AccountResource._allowed_filters

    before { create_list(:account, 2, contractor: customer) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/accounts/:id' do
    let(:id) { create(:account, contractor: customer).reload.uuid }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
