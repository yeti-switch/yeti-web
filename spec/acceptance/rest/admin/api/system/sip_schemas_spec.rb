# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'SIP Schemas' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'sip-schemas' }

  get '/api/rest/admin/system/sip-schemas' do
    jsonapi_filters Api::Rest::Admin::System::SipSchemaResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/system/sip-schemas/:id' do
    let(:id) { System::SipSchema.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
