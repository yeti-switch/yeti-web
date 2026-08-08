# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::RoutingPlansController, type: :request do
  include_context :json_api_admin_helpers, type: :'routing-plans'

  describe 'GET /api/rest/admin/routing-plans' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:routing_plans) do
      FactoryBot.create_list(:routing_plan, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        routing_plans.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end

  describe 'GET /api/rest/admin/routing-plans/{id}' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:json_api_request_query) { nil }
    let(:record_id) { routing_plan.id.to_s }
    let!(:routing_plan) { FactoryBot.create(:routing_plan, :with_static_routes) }
    let!(:static_routes) { FactoryBot.create_list(:routing_plan_static_route, 2, routing_plan: routing_plan) }

    include_examples :returns_json_api_record, relationships: %i[routing-groups static-routes] do
      let(:json_api_record_id) { record_id }
      let(:json_api_record_attributes) { be_present }
    end

    context 'with include=static-routes' do
      let(:json_api_request_query) { { include: 'static-routes' } }

      it 'includes static routes' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data][:relationships][:'static-routes'][:data]).to match_array(
          static_routes.map { |r| { id: r.id.to_s, type: 'routing-plan-static-routes' } }
        )
        expect(response_json[:included]).to match_array(
          static_routes.map { |r| hash_including(id: r.id.to_s, type: 'routing-plan-static-routes') }
        )
      end
    end
  end
end
