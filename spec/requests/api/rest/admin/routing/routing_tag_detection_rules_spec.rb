# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::RoutingTagDetectionRulesController, type: :request do
  include_context :json_api_admin_helpers, type: :'routing-tag-detection-rules', prefix: 'routing'

  describe 'GET /api/rest/admin/equipment/routing-tag-detection-rules' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:routing_tag_detection_rules) do
      FactoryBot.create_list(:routing_tag_detection_rule, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        routing_tag_detection_rules.map { |r| r.id.to_s }
      end
    end
  end
end
