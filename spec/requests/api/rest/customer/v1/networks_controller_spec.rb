# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::NetworksController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :networks

  describe 'GET /api/rest/customer/v1/networks' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    before do
      System::NetworkPrefix.delete_all
      System::Network.delete_all
    end
    let!(:networks) do
      [
        FactoryBot.create(:network, name: 'US').reload,
        FactoryBot.create(:network, name: 'Canada').reload
      ]
    end

    it_behaves_like :json_api_customer_v1_check_authorization

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { networks.map(&:uuid) }
    end
  end

  describe 'GET /api/rest/customer/v1/networks/{id}' do
    subject do
      get json_api_request_path, params: json_api_query_params, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network.uuid }

    let!(:network) { System::Network.take! }

    it_behaves_like :json_api_customer_v1_check_authorization

    include_examples :returns_json_api_record, relationships: [:'network-type'] do
      let(:json_api_record_id) { network.uuid }
      let(:json_api_record_attributes) { { name: network.name } }
    end

    context 'include network-type' do
      let(:json_api_query_params) { { include: 'network-type' } }
      let(:network_type) { network.network_type.reload }

      include_examples :returns_json_api_record_relationship, :'network-type' do
        let(:json_api_relationship_data) { { id: network_type.uuid, type: 'network-types' } }
      end

      include_examples :returns_json_api_record_include, type: :'network-types' do
        let(:json_api_include_id) { network_type.uuid }
        let(:json_api_include_attributes) { { name: network_type.name } }
      end
    end
  end

  describe 'PUT /api/rest/customer/v1/networks/{id}' do
    subject do
      put json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network.uuid }
    let(:json_api_request_data) { super().merge(id: record_id) }
    let(:json_api_request_attributes) { { name: 'new name' } }

    let!(:network) { System::Network.take! }

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'PATCH /api/rest/customer/v1/networks/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network.uuid }
    let(:json_api_request_data) { super().merge(id: record_id) }
    let(:json_api_request_attributes) { { name: 'new name' } }

    let!(:network) { System::Network.take! }

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'DELETE /api/rest/customer/v1/networks/{id}' do
    subject do
      delete json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network.uuid }

    let!(:network) { System::Network.take! }

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'POST /api/rest/customer/v1/networks' do
    subject do
      post json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_attributes) { { name: 'new name' } }

    include_examples :raises_exception, ActionController::RoutingError
  end
end
