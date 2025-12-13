# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Routing Area' do
  include_context :acceptance_admin_user

  let(:collection) { create_list(:area, 2) }
  let(:record) { collection.first }

  required_params = %i[name]
  optional_params = %i[]

  required_relationships = %i[]
  optional_relationships = %i[]

  include_context :acceptance_index_show, type: 'areas', filters: Api::Rest::Admin::AreaResource._allowed_filters
  include_context :acceptance_delete, type: 'areas'

  post '/api/rest/admin/areas' do
    parameter :type, 'Resource type (areas)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:name) { 'test-area' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/areas/:id' do
    parameter :type, 'Resource type (areas)', scope: :data, required: true
    parameter :id, 'Area ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:id) { create(:area).id }
    let(:name) { 'test-area' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end
end
