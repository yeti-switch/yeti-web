# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::ServicesController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :services

  let!(:service) { FactoryBot.create(:service, uuid: SecureRandom.uuid) }
  let(:json_api_request_query) { { include: :transactions } }

  describe 'GET /api/rest/customer/v1/services?include=transactions' do
    subject { get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers }

    it 'should render records with included service' do
      subject

      expect(response_json[:errors]).to eq nil
      expect(response_json[:data].pluck(:id)).to match_array [service.uuid]
      expect(response_json[:included]).to contain_exactly(
        hash_including(
          id: service.transactions.first.uuid,
          type: 'transactions'
        )
      )
    end
  end

  describe 'GET /api/rest/customer/v1/services/{id}?include=transactions' do
    subject { get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers }

    let(:json_api_request_path) { "#{super()}/#{service.uuid}" }

    it 'should return record with included service' do
      subject

      expect(response_json.dig(:data, :id)).to eq service.uuid
      expect(response_json.dig(:included)).to contain_exactly hash_including id: service.transactions.first.uuid, type: 'transactions'
    end
  end
end
