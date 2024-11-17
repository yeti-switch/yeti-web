# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Gateway inband dtmf filtering mode' do
  include_context :acceptance_admin_user
  let(:type) { 'gateway-inband-dtmf-filtering-modes' }

  get '/api/rest/admin/gateway-inband-dtmf-filtering-modes' do
    jsonapi_filters Api::Rest::Admin::GatewayInbandDtmfFilteringModeResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/gateway-inband-dtmf-filtering-modes/:id' do
    let(:id) { Equipment::GatewayInbandDtmfFilteringMode.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
