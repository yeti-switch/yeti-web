require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Routing RoutingTagDetectionRules' do
  include_context :acceptance_admin_user

  include_context :init_routing_tag_collection

  let(:collection) { create_list :routing_tag_detection_rule, 2 }
  let(:record) { collection.first }

  required_params = %i()

  optional_params = %i(tag-action-value routing-tag-ids)

  required_relationships = %i()
  optional_relationships = %i(src-area dst-area tag-action)

  include_context :acceptance_index_show, namespace: 'routing', type: 'routing-tag-detection-rules'
  include_context :acceptance_delete, namespace: 'routing', type: 'routing-tag-detection-rules'

  post '/api/rest/admin/routing/routing-tag-detection-rules' do
    parameter :type, 'Resource type (routing-tag-detection-rules)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)


    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/routing/routing-tag-detection-rules/:id' do
    parameter :type, 'Resource type (routing-tag-detection-rules)', scope: :data, required: true
    parameter :id, 'ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:id) { record.id }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

end
