# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Transport protocol' do
  include_context :acceptance_admin_user
  let(:type) { 'transport-protocols' }

  get '/api/rest/admin/transport-protocols' do
    jsonapi_filters Api::Rest::Admin::TransportProtocolResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/transport-protocols/:id' do
    let(:id) { Equipment::TransportProtocol.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
