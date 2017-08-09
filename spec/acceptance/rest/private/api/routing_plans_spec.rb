require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Routing plans' do
  header 'Accept', 'application/json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  get '/api/rest/private/routing_plans' do
    before { create_list(:routing_plan, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/routing_plans/:id' do
    let(:id) { create(:routing_plan).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/routing_plans' do
    parameter :name, 'Routing plan name', scope: :routing_plan, required: true
    parameter :rate_delta_max, 'Rate delta max', scope: :routing_plan
    parameter :use_lnp, 'Use lnp flag', scope: :routing_plan
    parameter :sorting_id, 'Sorting id', scope: :routing_plan

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/routing_plans/:id' do
    parameter :name, 'Routing plan name', scope: :routing_plan, required: true
    parameter :rate_delta_max, 'Rate delta max', scope: :routing_plan
    parameter :use_lnp, 'Use lnp flag', scope: :routing_plan
    parameter :sorting_id, 'Sorting id', scope: :routing_plan

    let(:id) { create(:routing_plan).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(204)
    end
  end

  delete '/api/rest/private/routing_plans/:id' do
    let(:id) { create(:routing_plan).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
