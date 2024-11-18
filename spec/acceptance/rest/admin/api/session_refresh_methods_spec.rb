# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Session refresh methods' do
  include_context :acceptance_admin_user
  let(:type) { 'session-refresh-methods' }

  get '/api/rest/admin/session-refresh-methods' do
    jsonapi_filters Api::Rest::Admin::SessionRefreshMethodResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/session-refresh-methods/:id' do
    let(:id) { SessionRefreshMethod.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
