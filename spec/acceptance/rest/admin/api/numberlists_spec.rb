# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Numberlist' do
  include_context :acceptance_admin_user

  let(:collection) { create_list(:numberlist, 2) }
  let(:record) { create(:numberlist) }

  required_params = %i[name]

  optional_params = %i[
    default-action-id
    mode-id
    default-src-rewrite-rule
    default-src-rewrite-result
    defer-src-rewrite
    default-dst-rewrite-rule
    default-dst-rewrite-result
    defer-dst-rewrite
    tag-action-value
    variables
    external-id
    external-type
  ]

  required_relationships = %i[]

  optional_relationships = %i[
    tag-action
  ]

  include_context :acceptance_index_show, type: 'numberlists', filters: Api::Rest::Admin::NumberlistResource._allowed_filters
  include_context :acceptance_delete, type: 'numberlists'

  post '/api/rest/admin/numberlists' do
    parameter :type, 'Resource type (numberlist)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:name) { 'name' }
    let(:variables) { { 'var1' => 'value1', 'var2' => 10 } }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/numberlists/:id' do
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
