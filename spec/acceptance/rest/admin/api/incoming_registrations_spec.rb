# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'IncomingRegistrations' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'incoming-registrations' }

  before { FactoryBot.create(:node) }
  include_context :incoming_registrations_stub_helpers

  get '/api/rest/admin/incoming-registrations' do
    jsonapi_filters Api::Rest::Admin::IncomingRegistrationResource._allowed_filters

    before { stub_incoming_registrations_collection }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end
end
