require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Sdp c locations' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'sdp-c-locations' }

  get '/api/rest/admin/sdp-c-locations' do

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/sdp-c-locations/:id' do
    let(:id) { SdpCLocation.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

end
