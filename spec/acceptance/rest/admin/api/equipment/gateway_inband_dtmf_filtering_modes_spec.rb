require 'spec_helper'


RSpec.resource 'Gateway inband dtmf filtering mode' do

  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'gateway-inband-dtmf-filtering-modes' }

  get '/api/rest/admin/equipment/gateway-inband-dtmf-filtering-modes' do

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/equipment/gateway-inband-dtmf-filtering-modes/:id' do
    let(:id) { Equipment::GatewayInbandDtmfFilteringMode.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

end
