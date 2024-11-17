# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Dtmf send modes' do
  include_context :acceptance_admin_user
  let(:type) { 'dtmf-send-modes' }

  get '/api/rest/admin/dtmf-send-modes' do
    jsonapi_filters Api::Rest::Admin::DtmfSendModeResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/dtmf-send-modes/:id' do
    let(:id) { System::DtmfSendMode.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
