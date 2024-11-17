# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Sdp c locations' do
  include_context :acceptance_admin_user
  let(:type) { 'sdp-c-locations' }

  get '/api/rest/admin/sdp-c-locations' do
    jsonapi_filters Api::Rest::Admin::SdpCLocationResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/sdp-c-locations/:id' do
    let(:id) { SdpCLocation.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
