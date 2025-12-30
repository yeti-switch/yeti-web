# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Routing NumberlistItems' do
  include_context :acceptance_admin_user

  let(:record) { create(:numberlist_item) }
  let(:type) { 'numberlist-items' }

  required_params = %i[key]

  optional_params = %i[
    src_rewrite_rule src_rewrite_result defer_src_rewrite
    dst_rewrite_rule dst_rewrite_result defer_dst_rewrite
    tag_action_value variables
  ]

  required_relationships = %i[numberlist]

  optional_relationships = %i[
    action
    tag-action
  ]

  get '/api/rest/admin/numberlist-items' do
    jsonapi_filters Api::Rest::Admin::NumberlistItemResource._allowed_filters

    let(:collection) { create_list(:numberlist_item, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/numberlist-items/:id' do
    let(:id) { record.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  include_context :acceptance_delete, type: 'numberlist-items'

  post '/api/rest/admin/numberlist-items' do
    parameter :type, 'Resource type (numberlist-items)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:key) { '123' }
    let(:numberlist) { wrap_relationship(:numberlists, create(:numberlist).id) }
    let(:variables) { { 'var1' => 'value1', 'var2' => 10 } }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/numberlist-items/:id' do
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
