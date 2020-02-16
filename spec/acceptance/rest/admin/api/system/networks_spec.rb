# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Networks' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'networks' }

  required_params = %i[name]
  required_relationships = %i[network-type]

  get '/api/rest/admin/system/networks' do
    jsonapi_filters Api::Rest::Admin::System::NetworkResource._allowed_filters

    before do
      FactoryGirl.create(:network, name: 'US')
      FactoryGirl.create(:network, name: 'CA')
    end

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/system/networks/:id' do
    let(:id) { FactoryGirl.create(:network, name: 'US').id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/system/networks' do
    parameter :type, 'Resource type (networks)', scope: :data, required: true

    jsonapi_attributes(required_params, [])
    jsonapi_relationships(required_relationships, [])

    let(:name) { 'name' }
    let(:'network-type') { wrap_relationship(:network_types, network_type.id) }

    let!(:network_type) { create(:network_type) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/system/networks/:id' do
    parameter :type, 'Resource type (networks)', scope: :data, required: true
    parameter :id, 'Network ID', scope: :data, required: true

    jsonapi_attributes(required_params, [])
    jsonapi_relationships(required_relationships, [])

    let!(:network) { create(:network, name: 'US') }
    let!(:network_type) { create(:network_type) }
    let(:id) { network.id }
    let(:name) { 'name' }
    let(:'network-type') { wrap_relationship(:network_types, network_type.id) }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/system/networks/:id' do
    let(:id) { FactoryGirl.create(:network, name: 'US').id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
