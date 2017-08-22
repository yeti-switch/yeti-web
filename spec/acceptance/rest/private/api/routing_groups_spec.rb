require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Routing groups' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'routing-groups' }

  get '/api/rest/private/routing-groups' do
    before { create_list(:routing_group, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/routing-groups/:id' do
    let(:id) { create(:routing_group).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/routing-groups' do
    parameter :type, 'Resource type (routing-groups)', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/routing-groups/:id' do
    parameter :type, 'Resource type (routing-groups)', scope: :data, required: true
    parameter :id, 'Routing group ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:routing_group).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/routing-groups/:id' do
    let(:id) { create(:routing_group).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
