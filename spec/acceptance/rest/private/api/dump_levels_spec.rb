require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Dump levels' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'dump-levels' }

  get '/api/rest/private/dump-levels' do
    before { create_list(:dump_level, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/dump-levels/:id' do
    let(:id) { create(:dump_level).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/dump-levels' do
    parameter :type, 'Resource type (dump-levels)', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/dump-levels/:id' do
    parameter :type, 'Resource type (dump-levels)', scope: :data, required: true
    parameter :id, 'Dump level ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:dump_level).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/dump-levels/:id' do
    let(:id) { create(:dump_level).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
