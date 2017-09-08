require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Gateway rel100 modes' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'gateway-rel100-modes' }

  get '/api/rest/admin/equipment/gateway-rel100-modes' do

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/equipment/gateway-rel100-modes/:id' do
    let(:id) { Equipment::GatewayRel100Mode.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

end
