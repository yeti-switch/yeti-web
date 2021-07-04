# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::NetworkTypesController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :'network-types'

  describe 'GET /api/rest/customer/v1/network-types' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    before { create_list(:network_type, 2) }
    let!(:network_types) do
      System::NetworkType.all.to_a
    end

    it_behaves_like :json_api_check_authorization

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { network_types.map(&:uuid) }
    end
  end

  describe 'GET /api/rest/customer/v1/network-types/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network_type.uuid }

    let!(:network_type) { FactoryBot.create(:network_type).reload }

    it_behaves_like :json_api_check_authorization

    include_examples :returns_json_api_record do
      let(:json_api_record_id) { network_type.uuid }
      let(:json_api_record_attributes) { { name: network_type.name } }
    end
  end

  describe 'PUT /api/rest/customer/v1/network-types/{id}' do
    subject do
      put json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network_type.uuid }
    let(:json_api_request_data) { super().merge(id: record_id) }
    let(:json_api_request_attributes) { { name: 'new name' } }

    let!(:network_type) { FactoryBot.create(:network_type).reload }

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'PATCH /api/rest/customer/v1/network-types/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network_type.uuid }
    let(:json_api_request_data) { super().merge(id: record_id) }
    let(:json_api_request_attributes) { { name: 'new name' } }

    let!(:network_type) { FactoryBot.create(:network_type).reload }

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'DELETE /api/rest/customer/v1/network-types/{id}' do
    subject do
      delete json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network_type.uuid }

    let!(:network_type) { FactoryBot.create(:network_type).reload }

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'POST /api/rest/customer/v1/network-types' do
    subject do
      post json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_attributes) { { name: 'new name' } }

    include_examples :raises_exception, ActionController::RoutingError
  end
end
