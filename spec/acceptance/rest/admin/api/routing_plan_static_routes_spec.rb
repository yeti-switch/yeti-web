# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Routing plan static routes' do
  include_context :acceptance_admin_user
  let(:type) { 'routing-plan-static-routes' }

  required_params = %i[prefix]
  optional_params = %i[priority weight]
  required_relationships = %i[routing-plan vendor]

  get '/api/rest/admin/routing-plan-static-routes' do
    jsonapi_filters Api::Rest::Admin::RoutingPlanStaticRouteResource._allowed_filters

    before { create_list(:routing_plan_static_route, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/routing-plan-static-routes/:id' do
    let(:id) { create(:routing_plan_static_route).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/routing-plan-static-routes' do
    parameter :type, 'Resource type (routing-plan-static-routes)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, [])

    let(:prefix) { '1234' }
    let(:priority) { 100 }
    let(:weight) { 100 }
    let(:'routing-plan') { wrap_relationship(:routing_plans, create(:routing_plan, :with_static_routes).id) }
    let(:vendor) { wrap_relationship(:contractors, create(:vendor).id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/routing-plan-static-routes/:id' do
    parameter :type, 'Resource type (routing-plan-static-routes)', scope: :data, required: true
    parameter :id, 'Routing plan static route ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:id) { create(:routing_plan_static_route).id }
    let(:prefix) { '5678' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/routing-plan-static-routes/:id' do
    let(:id) { create(:routing_plan_static_route).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
