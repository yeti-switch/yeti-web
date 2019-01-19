# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Auth profiles' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'auth-profiles' }

  required_params = %i[name server port secret timeout attempts]
  optional_params = %i[enable-start-accounting enable-interim-accounting interim-accounting-interval enable-stop-accounting]

  get '/api/rest/admin/equipment/radius/auth-profiles' do
    before { create_list(:auth_profile, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/equipment/radius/auth-profiles/:id' do
    let(:id) { create(:auth_profile).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/equipment/radius/auth-profiles' do
    parameter :type, 'Resource type (auth-profiles)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:name)   { 'name' }
    let(:server) { 'server' }
    let(:port)   { '1' }
    let(:secret) { 'secret' }
    let(:timeout) { 100 }
    let(:attempts) { 2 }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/equipment/radius/auth-profiles/:id' do
    parameter :type, 'Resource type (auth-profiles)', scope: :data, required: true
    parameter :id, 'Auth profile ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:id) { create(:auth_profile).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/equipment/radius/auth-profiles/:id' do
    let(:id) { create(:auth_profile).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
