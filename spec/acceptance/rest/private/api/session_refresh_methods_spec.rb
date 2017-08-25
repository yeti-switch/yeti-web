require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Session refresh methods' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'session-refresh-methods' }

  get '/api/rest/private/session-refresh-methods' do
    # before { create_list(:filter_type, 2) }
    before do
      SessionRefreshMethod.create(name: 'name')
    end
    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/session-refresh-methods/:id' do
    # let(:id) { create(:filter_type).id }
    let(:id) { SessionRefreshMethod.create(name: 'name').id }


    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/session-refresh-methods' do
    parameter :type, 'Resource type (session-refresh-methods)', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/session-refresh-methods/:id' do
    parameter :type, 'Resource type (session-refresh-methods)', scope: :data, required: true
    parameter :id, 'Session refresh method ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { SessionRefreshMethod.create(name: 'name').id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/session-refresh-methods/:id' do
    let(:id) { SessionRefreshMethod.create(name: 'name').id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
