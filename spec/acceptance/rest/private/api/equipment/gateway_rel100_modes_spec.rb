require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Gateway rel100 modes' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'gateway-rel100-modes' }

  get '/api/rest/private/equipment/gateway-rel100-modes' do
    before { create_list(:gateway_rel100_mode, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/equipment/gateway-rel100-modes/:id' do
    let(:id) { create(:gateway_rel100_mode).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/equipment/gateway-rel100-modes' do
    parameter :type, 'Resource type (gateway-rel100-modes)', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:name) { 'name' }

    example_request 'create new entry' do
      Rails.logger.info 'jjjj'
      Rails.logger.info response_body
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/equipment/gateway-rel100-modes/:id' do
    parameter :type, 'Resource type (gateway-rel100-modes)', scope: :data, required: true
    parameter :id, 'Gateway rel100 mode ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:gateway_rel100_mode).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/equipment/gateway-rel100-modes/:id' do
    let(:id) { create(:gateway_rel100_mode).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
