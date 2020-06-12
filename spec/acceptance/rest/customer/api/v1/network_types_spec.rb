# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'NetworkTypes', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }
  let(:type) { 'network-types' }

  let!(:network_type) { FactoryBot.create(:network_type).reload }

  get '/api/rest/customer/v1/network-types' do
    jsonapi_filters Api::Rest::Customer::V1::NetworkTypeResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/network-types/:id' do
    let(:id) { network_type.uuid }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
