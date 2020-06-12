# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::NetworkPrefixesController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :'network-prefixes'

  describe 'GET /api/rest/customer/v1/network-prefixes' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_query) { nil }

    let!(:network_prefixes) do
      [
        FactoryBot.create(:network_prefix).reload,
        FactoryBot.create(:network_prefix).reload
      ]
    end

    it_behaves_like :json_api_check_authorization

    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { network_prefixes.map(&:uuid) }
    end
  end

  describe 'GET /api/rest/customer/v1/network-prefixes/{id}' do
    subject do
      get json_api_request_path, params: json_api_query_params, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network_prefix.uuid }

    let!(:network_prefix) { FactoryBot.create(:network_prefix).reload }

    it_behaves_like :json_api_check_authorization

    include_examples :returns_json_api_record, relationships: [:network] do
      let(:json_api_record_id) { network_prefix.uuid }
      let(:json_api_record_attributes) do
        {
          prefix: network_prefix.prefix,
          'number-min-length': network_prefix.number_min_length,
          'number-max-length': network_prefix.number_max_length
        }
      end
    end

    context 'include network' do
      let(:json_api_query_params) { { include: 'network' } }
      let(:network) { network_prefix.network.reload }

      include_examples :returns_json_api_record_relationship, :network do
        let(:json_api_relationship_data) { { id: network.uuid, type: 'networks' } }
      end

      include_examples :returns_json_api_record_include, type: :networks do
        let(:json_api_include_id) { network.uuid }
        let(:json_api_include_attributes) { { name: network.name } }
      end
    end
  end

  describe 'PUT /api/rest/customer/v1/network-prefixes/{id}' do
    subject do
      put json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network_prefix.uuid }
    let(:json_api_request_data) { super().merge(id: record_id) }
    let(:json_api_request_attributes) { { name: 'new name' } }

    let!(:network_prefix) { FactoryBot.create(:network_prefix).reload }

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'PATCH /api/rest/customer/v1/network-prefixes/{id}' do
    subject do
      patch json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network_prefix.uuid }
    let(:json_api_request_data) { super().merge(id: record_id) }
    let(:json_api_request_attributes) { { name: 'new name' } }

    let!(:network_prefix) { FactoryBot.create(:network_prefix).reload }

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'DELETE /api/rest/customer/v1/network-prefixes/{id}' do
    subject do
      delete json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { network_prefix.uuid }

    let!(:network_prefix) { FactoryBot.create(:network_prefix).reload }

    include_examples :raises_exception, ActionController::RoutingError
  end

  describe 'POST /api/rest/customer/v1/network-prefixes' do
    subject do
      post json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_attributes) { { name: 'new name' } }

    include_examples :raises_exception, ActionController::RoutingError
  end
end
