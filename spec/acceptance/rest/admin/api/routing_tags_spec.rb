# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Routing RoutingTag' do
  include_context :acceptance_admin_user

  include_context :init_routing_tag_collection

  let(:collection) { Routing::RoutingTag.all }
  let(:record) { Routing::RoutingTag.take }

  required_params = %i[name]

  optional_params = %i[]

  required_relationships = %i[]

  optional_relationships = %i[]

  include_context :acceptance_index_show, type: 'routing-tags', filters: Api::Rest::Admin::RoutingTagResource._allowed_filters
  include_context :acceptance_delete, type: 'routing-tags'

  post '/api/rest/admin/routing-tags' do
    parameter :type, 'Resource type (routing-tags)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/routing-tags/:id' do
    parameter :type, 'Resource type (routing-tags)', scope: :data, required: true
    parameter :id, 'Customer Auth ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:id) { record.id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end
end
