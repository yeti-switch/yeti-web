# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Gateway Network protocol priorities' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'gateway-network-protocol-priorities' }

  get '/api/rest/admin/gateway-network-protocol-priorities' do
    jsonapi_filters Api::Rest::Admin::GatewayNetworkProtocolPriorityResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/gateway-network-protocol-priorities/:id' do
    let(:id) { Equipment::GatewayNetworkProtocolPriority.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
