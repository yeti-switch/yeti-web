# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Nodes' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'nodes' }

  get '/api/rest/admin/nodes' do
    jsonapi_filters Api::Rest::Admin::NodeResource._allowed_filters

    before do
      create(:node)
    end
    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/nodes/:id' do
    let(:id) { create(:node).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/nodes' do
    parameter :type, 'Resource type (nodes)', scope: :data, required: true
    parameter :id, 'Node ID', scope: :data, required: true

    jsonapi_attributes(%i[name rpc-endpoint], [])
    jsonapi_relationships([:pop], [])

    let(:id) { 11 }
    let(:name) { 'name' }
    let(:'rpc-endpoint') { '127.0.0.1:8099' }
    let(:pop) { wrap_relationship(:pops, create(:pop).id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/nodes/:id' do
    parameter :type, 'Resource type (nodes)', scope: :data, required: true
    parameter :id, 'Node ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:node).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/nodes/:id' do
    let(:id) { create(:node).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
