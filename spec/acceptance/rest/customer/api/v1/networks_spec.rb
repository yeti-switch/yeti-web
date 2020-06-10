# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Networks', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }
  let(:type) { 'networks' }

  let!(:network) { FactoryBot.create(:network, name: 'US').reload }

  get '/api/rest/customer/v1/networks' do
    jsonapi_filters Api::Rest::Customer::V1::NetworkResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/networks/:id' do
    let(:id) { network.uuid }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
