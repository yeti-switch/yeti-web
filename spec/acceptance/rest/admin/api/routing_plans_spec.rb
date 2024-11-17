# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Routing plans' do
  include_context :acceptance_admin_user
  let(:type) { 'routing-plans' }

  get '/api/rest/admin/routing-plans' do
    jsonapi_filters Api::Rest::Admin::RoutingPlanResource._allowed_filters

    before { create_list(:routing_plan, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/routing-plans/:id' do
    let(:id) { create(:routing_plan).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/routing-plans' do
    parameter :type, 'Resource type (routing-plans)', scope: :data, required: true

    jsonapi_attributes([:name], %i[rate_delta_max use_lnp max_rerouting_attempts])
    jsonapi_relationships([], [:sorting])

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/routing-plans/:id' do
    parameter :type, 'Resource type (routing-plans)', scope: :data, required: true
    parameter :id, 'Routing plan ID', scope: :data, required: true

    jsonapi_attributes([:name], %i[rate_delta_max use_lnp max_rerouting_attempts])

    let(:id) { create(:routing_plan).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/routing-plans/:id' do
    let(:id) { create(:routing_plan).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
