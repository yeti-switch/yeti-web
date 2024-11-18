# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Gateway Network protocol priorities' do
  include_context :acceptance_admin_user
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
