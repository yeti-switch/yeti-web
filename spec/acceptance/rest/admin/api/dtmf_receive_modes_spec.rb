# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Dtmf receive modes' do
  include_context :acceptance_admin_user
  let(:type) { 'dtmf-receive-modes' }

  get '/api/rest/admin/dtmf-receive-modes' do
    jsonapi_filters Api::Rest::Admin::DtmfReceiveModeResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/dtmf-receive-modes/:id' do
    let(:id) { System::DtmfReceiveMode.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
