# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Routing NumberlistItems' do
  include_context :acceptance_admin_user

  let(:collection) { create_list(:numberlist_item, 2) }
  let(:record) { create(:numberlist_item) }

  required_params = %i[key]

  optional_params = %i[
    src_rewrite_rule src_rewrite_result
    dst_rewrite_rule dst_rewrite_result
    tag_action_value
  ]

  required_relationships = %i[numberlist]

  optional_relationships = %i[
    action
    tag-action
  ]

  include_context :acceptance_index_show, namespace: 'routing', type: 'numberlist-items'
  include_context :acceptance_delete, namespace: 'routing', type: 'numberlist-items'

  post '/api/rest/admin/routing/numberlist-items' do
    parameter :type, 'Resource type (numberlist-items)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:key) { '123' }
    let(:numberlist) { wrap_relationship(:numberlists, create(:numberlist).id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/routing/numberlist-items/:id' do
    parameter :type, 'Resource type (numberlist-items)', scope: :data, required: true
    parameter :id, 'Numberlist Item ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:id) { record.id }
    let(:key) { '123' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end
end
