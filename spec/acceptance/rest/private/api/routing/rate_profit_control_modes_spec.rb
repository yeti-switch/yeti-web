require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Rate profit control modes' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'rate-profit-control-modes' }

  get '/api/rest/private/routing/rate-profit-control-modes' do
    before { create_list(:rate_profit_control_mode, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/routing/rate-profit-control-modes/:id' do
    let(:id) { create(:rate_profit_control_mode).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/routing/rate-profit-control-modes' do
    parameter :type, 'Resource type (rate-profit-control-modes)', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/routing/rate-profit-control-modes/:id' do
    parameter :type, 'Resource type (rate-profit-control-modes)', scope: :data, required: true
    parameter :id, 'Rate profit control mode ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:rate_profit_control_mode).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/routing/rate-profit-control-modes/:id' do
    let(:id) { create(:rate_profit_control_mode).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
