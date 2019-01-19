# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Numberlist' do
  include_context :acceptance_admin_user

  let(:collection) { create_list(:numberlist, 2) }
  let(:record) { create(:numberlist) }

  required_params = %i[name]

  optional_params = %i[
    default-src-rewrite-rule default-src-rewrite-result
    default-dst-rewrite-rule default-dst-rewrite-result
    tag-action-value
  ]

  required_relationships = %i[]

  optional_relationships = %i[
    tag-action
  ]

  include_context :acceptance_index_show, namespace: 'routing', type: 'numberlists'
  include_context :acceptance_delete, namespace: 'routing', type: 'numberlists'

  post '/api/rest/admin/routing/numberlists' do
    parameter :type, 'Resource type (numberlist)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/routing/numberlists/:id' do
    parameter :type, 'Resource type (numberlist)', scope: :data, required: true
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
