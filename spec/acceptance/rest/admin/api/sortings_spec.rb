# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Sortings' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'sortings' }

  get '/api/rest/admin/sortings' do
    jsonapi_filters Api::Rest::Admin::SortingResource._allowed_filters

    before do
      Sorting.create(name: 'name')
    end
    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/sortings/:id' do
    let(:id) { Sorting.create(name: 'name').id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/sortings' do
    parameter :type, 'Resource type (sortings)', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/sortings/:id' do
    parameter :type, 'Resource type (sortings)', scope: :data, required: true
    parameter :id, 'Sorting ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { Sorting.create(name: 'name').id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/sortings/:id' do
    let(:id) { Sorting.create(name: 'name').id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
