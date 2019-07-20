# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'IncomingRegistrations' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'incoming-registrations' }

  before { FactoryGirl.create(:node) }
  include_context :incoming_registrations_stub_helpers

  get '/api/rest/admin/incoming-registrations' do
    before { stub_incoming_registrations_collection }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end
end
