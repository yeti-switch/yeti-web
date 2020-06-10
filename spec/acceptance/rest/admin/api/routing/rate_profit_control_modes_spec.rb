# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Rate profit control modes' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'rate-profit-control-modes' }

  get '/api/rest/admin/routing/rate-profit-control-modes' do
    jsonapi_filters Api::Rest::Admin::Routing::RateProfitControlModeResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/routing/rate-profit-control-modes/:id' do
    let(:id) { Routing::RateProfitControlMode.take.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
