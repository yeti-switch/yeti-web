require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Routing groups' do
  header 'Accept', 'application/json'

  get '/api/rest/private/routing_groups' do
    before { create_list(:routing_group, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/routing_groups/:id' do
    let(:id) { create(:routing_group).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/routing_groups' do
    parameter :name, 'Routing group name', scope: :routing_group, required: true

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/routing_groups/:id' do
    parameter :name, 'Routing group name', scope: :routing_group, required: true

    let(:id) { create(:routing_group).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(204)
    end
  end

  delete '/api/rest/private/routing_groups/:id' do
    let(:id) { create(:routing_group).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
