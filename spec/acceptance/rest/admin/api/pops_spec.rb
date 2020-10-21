# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Pops' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'pops' }

  get '/api/rest/admin/pops' do
    jsonapi_filters Api::Rest::Admin::PopResource._allowed_filters

    before do
      create(:pop)
    end
    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/pops/:id' do
    let(:id) { create(:pop).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/pops' do
    parameter :type, 'Resource type (pops)', scope: :data, required: true
    parameter :id, 'POP ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { 11 }
    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/pops/:id' do
    parameter :type, 'Resource type (pops)', scope: :data, required: true
    parameter :id, 'POP ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:pop).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/pops/:id' do
    let(:id) { create(:pop).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
