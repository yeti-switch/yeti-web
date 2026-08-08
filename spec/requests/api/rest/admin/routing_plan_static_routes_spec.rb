# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::RoutingPlanStaticRoutesController, type: :request do
  include_context :json_api_admin_helpers, type: :'routing-plan-static-routes'

  describe 'GET /api/rest/admin/routing-plan-static-routes' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }
    let!(:static_routes) { FactoryBot.create_list(:routing_plan_static_route, 2) }

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { static_routes.map { |r| r.id.to_s } }
    end

    it_behaves_like :json_api_admin_check_authorization

    context 'with ransack filters' do
      let(:factory) { :routing_plan_static_route }

      it_behaves_like :jsonapi_filters_by_string_field, :prefix
      it_behaves_like :jsonapi_filters_by_number_field, :priority
      it_behaves_like :jsonapi_filters_by_number_field, :weight

      it_behaves_like :jsonapi_filters_by_foreign_key, :routing_plan_id do
        let(:foreign_keys_to_ids) do
          static_routes.group_by(&:routing_plan_id).transform_values { |records| records.map(&:id) }
        end
        let!(:static_routes) { FactoryBot.create_list(:routing_plan_static_route, 3) }
      end

      it_behaves_like :jsonapi_filters_by_foreign_key, :vendor_id do
        let(:foreign_keys_to_ids) do
          static_routes.group_by(&:vendor_id).transform_values { |records| records.map(&:id) }
        end
        let!(:static_routes) { FactoryBot.create_list(:routing_plan_static_route, 3) }
      end
    end
  end

  describe 'GET /api/rest/admin/routing-plan-static-routes/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { static_route.id.to_s }
    let!(:static_route) { FactoryBot.create(:routing_plan_static_route, prefix: '1234', priority: 10, weight: 20) }

    include_examples :returns_json_api_record, relationships: %i[routing-plan vendor] do
      let(:json_api_record_id) { record_id }
      let(:json_api_record_attributes) do
        {
          prefix: '1234',
          priority: 10,
          weight: 20,
          'network-prefix-id': static_route.network_prefix_id
        }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
  end

  describe 'POST /api/rest/admin/routing-plan-static-routes' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:routing_plan) { FactoryBot.create(:routing_plan, :with_static_routes) }
    let(:vendor) { FactoryBot.create(:vendor) }

    let(:json_api_request_body) do
      {
        data: {
          type: json_api_resource_type,
          attributes: json_api_request_attributes,
          relationships: json_api_request_relationships
        }
      }
    end
    let(:json_api_request_attributes) do
      { prefix: '1234', priority: 10, weight: 20 }
    end
    let(:json_api_request_relationships) do
      {
        'routing-plan': { data: { id: routing_plan.id.to_s, type: 'routing_plans' } },
        'vendor': { data: { id: vendor.id.to_s, type: 'contractors' } }
      }
    end
    let(:last_static_route) { Routing::RoutingPlanStaticRoute.last! }

    include_examples :returns_json_api_record, relationships: %i[routing-plan vendor], status: 201 do
      let(:json_api_record_id) { last_static_route.id.to_s }
      let(:json_api_record_attributes) do
        {
          prefix: '1234',
          priority: 10,
          weight: 20,
          'network-prefix-id': last_static_route.network_prefix_id
        }
      end
    end

    include_examples :changes_records_qty_of, Routing::RoutingPlanStaticRoute, by: 1

    it_behaves_like :json_api_admin_check_authorization, status: 201

    it 'assigns relationships and detects network prefix' do
      subject
      expect(last_static_route).to have_attributes(
        routing_plan_id: routing_plan.id,
        vendor_id: vendor.id,
        network_prefix_id: System::NetworkPrefix.longest_match('1234')&.id
      )
    end

    context 'with defaults only' do
      let(:json_api_request_attributes) { { prefix: '1234' } }

      include_examples :returns_json_api_record, relationships: %i[routing-plan vendor], status: 201 do
        let(:json_api_record_id) { last_static_route.id.to_s }
        let(:json_api_record_attributes) do
          {
            prefix: '1234',
            priority: 100,
            weight: 100,
            'network-prefix-id': last_static_route.network_prefix_id
          }
        end
      end
    end

    context 'when routing plan does not use static routes' do
      let(:routing_plan) { FactoryBot.create(:routing_plan) }

      include_examples :returns_json_api_errors, status: 422, errors: [
        { detail: 'routing-plan - is invalid' }
      ]
    end

    context 'when contractor is not a vendor' do
      let(:vendor) { FactoryBot.create(:customer) }

      include_examples :returns_json_api_errors, status: 422, errors: [
        { detail: 'vendor - must exist' },
        { detail: "vendor - can't be blank" }
      ]
    end

    context 'when prefix contains spaces' do
      let(:json_api_request_attributes) { { prefix: '12 34' } }

      include_examples :returns_json_api_errors, status: 422, errors: [
        { detail: 'prefix - is invalid', source: { pointer: '/data/attributes/prefix' } }
      ]
    end

    context 'when priority is out of range' do
      let(:json_api_request_attributes) { { prefix: '1234', priority: 0 } }

      include_examples :returns_json_api_errors, status: 422, errors: [
        { detail: 'priority - must be greater than 0', source: { pointer: '/data/attributes/priority' } }
      ]
    end

    context 'when weight is out of range' do
      let(:json_api_request_attributes) { { prefix: '1234', weight: 40_000 } }

      include_examples :returns_json_api_errors, status: 422, errors: [
        { detail: 'weight - must be less than or equal to 32767', source: { pointer: '/data/attributes/weight' } }
      ]
    end
  end

  describe 'PATCH /api/rest/admin/routing-plan-static-routes/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { static_route.id.to_s }
    let!(:static_route) { FactoryBot.create(:routing_plan_static_route, prefix: '1234', priority: 10, weight: 20) }

    let(:json_api_request_body) do
      { data: { id: record_id, type: json_api_resource_type, attributes: json_api_request_attributes } }
    end
    let(:json_api_request_attributes) { { prefix: '5678', priority: 55 } }

    include_examples :returns_json_api_record, relationships: %i[routing-plan vendor] do
      let(:json_api_record_id) { record_id }
      let(:json_api_record_attributes) { hash_including(prefix: '5678', priority: 55, weight: 20) }
    end

    it_behaves_like :json_api_admin_check_authorization

    it 're-detects network prefix on prefix change' do
      subject
      expect(static_route.reload.network_prefix_id).to eq(System::NetworkPrefix.longest_match('5678')&.id)
    end

    context 'with new vendor' do
      let(:new_vendor) { FactoryBot.create(:vendor) }
      let(:json_api_request_body) do
        {
          data: {
            id: record_id,
            type: json_api_resource_type,
            relationships: { 'vendor': { data: { id: new_vendor.id.to_s, type: 'contractors' } } }
          }
        }
      end

      it 'changes vendor' do
        expect { subject }.to change { static_route.reload.vendor_id }.to(new_vendor.id)
      end
    end

    context 'with invalid prefix' do
      let(:json_api_request_attributes) { { prefix: '12 34' } }

      include_examples :returns_json_api_errors, status: 422, errors: [
        { detail: 'prefix - is invalid', source: { pointer: '/data/attributes/prefix' } }
      ]
    end
  end

  describe 'DELETE /api/rest/admin/routing-plan-static-routes/{id}' do
    subject do
      delete json_api_request_path, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { static_route.id.to_s }
    let!(:static_route) { FactoryBot.create(:routing_plan_static_route) }

    include_examples :responds_with_status, 204
    include_examples :changes_records_qty_of, Routing::RoutingPlanStaticRoute, by: -1

    it_behaves_like :json_api_admin_check_authorization, status: 204
  end
end
