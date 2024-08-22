# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::TransactionsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :transactions

  let!(:service) { FactoryBot.create(:service, uuid: SecureRandom.uuid) }
  let(:json_api_request_query) { { include: :service } }

  describe 'GET /api/rest/customer/v1/transactions?include=service' do
    subject { get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers }

    it 'should render records with included service' do
      subject

      expect(response_json[:errors]).to eq nil
      expect(response_json[:data].pluck(:id)).to match_array [service.transactions.first.uuid]
      expect(response_json[:included]).to contain_exactly(
        hash_including(
          id: service.uuid,
          type: 'services',
          attributes: hash_including(name: service.name)
        )
      )
    end
  end

  describe 'GET /api/rest/customer/v1/transactions?filter[service-id-eq]=uuid' do
    subject { get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers }

    let(:json_api_request_query) { { filter: { 'service-id-eq' => service.uuid } } }

    it 'should filter records by UUID of service' do
      subject

      expect(response_json[:data].pluck(:id)).to contain_exactly service.transactions.first.uuid
    end
  end

  describe 'GET /api/rest/customer/v1/transactions/{id}?include=service' do
    subject { get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers }

    let(:json_api_request_path) { "#{super()}/#{service.transactions.first.uuid}" }

    it 'should return record with included service' do
      subject

      expect(response_json.dig(:data, :id)).to eq service.transactions.first.uuid
      expect(response_json.dig(:included)).to contain_exactly hash_including id: service.uuid, type: 'services'
    end
  end
end
