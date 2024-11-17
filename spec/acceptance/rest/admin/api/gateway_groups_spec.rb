# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Gateway groups' do
  include_context :acceptance_admin_user
  let(:type) { 'gateway-groups' }

  get '/api/rest/admin/gateway-groups' do
    jsonapi_filters Api::Rest::Admin::GatewayGroupResource._allowed_filters

    before { create_list(:gateway_group, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/gateway-groups/:id' do
    let(:id) { create(:gateway_group).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/gateway-groups' do
    parameter :type, 'Resource type (gateway-groups)', scope: :data, required: true

    jsonapi_attributes([:name], [])
    jsonapi_relationships([:vendor], [])

    let(:name) { 'name' }
    let(:vendor) { wrap_relationship(:contractors, create(:contractor, vendor: true).id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/gateway-groups/:id' do
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

  delete '/api/rest/admin/gateway-groups/:id' do
    let(:id) { create(:gateway_group).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
