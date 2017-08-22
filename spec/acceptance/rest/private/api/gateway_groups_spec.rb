require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Gateway groups' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'gateway-groups' }

  get '/api/rest/private/gateway-groups' do
    before { create_list(:gateway_group, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/gateway-groups/:id' do
    let(:id) { create(:gateway_group).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/gateway-groups' do
    parameter :type, 'Resource type (gateway-groups)', scope: :data, required: true

    jsonapi_attributes([:name], [])
    jsonapi_relationships([:vendor], [])

    let(:name) { 'name' }
    let(:vendor) { wrap_relationship(:contractors, create(:contractor, vendor: true).id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/gateway-groups/:id' do
    parameter :type, 'Resource type (gateway-groups)', scope: :data, required: true
    parameter :id, 'Gateway group ID', scope: :data, required: true

    jsonapi_attributes([:name], [])
    jsonapi_relationships([:vendor], [])

    let(:id) { create(:gateway_group).id }
    let(:name) { 'name' }
    let(:vendor) { wrap_relationship(:contractors, create(:contractor, vendor: true).id) }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/gateway-groups/:id' do
    let(:id) { create(:gateway_group).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
