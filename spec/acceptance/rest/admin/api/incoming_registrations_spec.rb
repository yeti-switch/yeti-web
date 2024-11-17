# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'IncomingRegistrations' do
  include_context :acceptance_admin_user
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
