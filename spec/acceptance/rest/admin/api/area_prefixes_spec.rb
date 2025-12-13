# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Routing AreaPrefix' do
  include_context :acceptance_admin_user

  let(:collection) { create_list(:area_prefix, 2) }
  let(:record) { collection.first }

  required_params = %i[prefix]
  optional_params = %i[]

  required_relationships = %i[area]
  optional_relationships = %i[]

  include_context :acceptance_index_show, type: 'area-prefixes', filters: Api::Rest::Admin::AreaPrefixResource._allowed_filters
  include_context :acceptance_delete, type: 'area-prefixes'

  post '/api/rest/admin/area-prefixes' do
    parameter :type, 'Resource type (area-prefixes)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:prefix) { '777' }
    let(:area) { wrap_relationship(:areas, create(:area).id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/area-prefixes/:id' do
    parameter :type, 'Resource type (area-prefixes)', scope: :data, required: true
    parameter :id, 'AreaPrefix ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:id) { create(:area_prefix).id }
    let(:prefix) { '765' }
    let(:area) { wrap_relationship(:areas, create(:area).id) }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end
end
