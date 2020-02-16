# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'NetworkTypes' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'network-types' }

  required_params = %i[name]

  get '/api/rest/admin/system/network-types' do
    jsonapi_filters Api::Rest::Admin::System::NetworkTypeResource._allowed_filters

    before do
      FactoryGirl.create_list(:network_type, 2)
    end

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/system/network-types/:id' do
    let(:id) { FactoryGirl.create(:network_type).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/system/network-types' do
    parameter :type, 'Resource type (network-types)', scope: :data, required: true

    jsonapi_attributes(required_params, [])

    let(:name) { 'name' }

    let!(:network_type) { create(:network_type) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/system/network-types/:id' do
    parameter :type, 'Resource type (network-types)', scope: :data, required: true
    parameter :id, 'Network Type ID', scope: :data, required: true

    jsonapi_attributes(required_params, [])

    let!(:network_type) { create(:network_type) }
    let(:id) { network_type.id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/system/network-types/:id' do
    let(:id) { FactoryGirl.create(:network_type).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
