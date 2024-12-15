# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::OriginationStatisticsQualityController do
  include_context :json_api_customer_v1_helpers, type: :accounts

  let(:auth_headers) { { 'Authorization' => json_api_auth_token } }

  describe 'GET /api/rest/customer/v1/origination-statistics-quality' do
    subject { get '/api/rest/customer/v1/origination-statistics-quality', params: query, headers: auth_headers }

    shared_examples :responds_400 do |error_message|
      it 'responds with correct error data' do
        expect(CaptureError).not_to receive(:capture)
        subject

        expect(response.status).to eq 400
        expect(response_json).to eq error: error_message
      end
    end

    shared_examples :responds_success do
      it 'responds with correct data' do
        expect(CaptureError).not_to receive(:capture)
        subject

        expect(response.status).to eq 200
        expect(response_json).to eq clickhouse_response_body
      end
    end

    let!(:account) { create(:account, contractor: customer) }
    let(:clickhouse_response_body) { [{ some_jey: 'value' }] }
    let(:from_time) { 1.day.ago.iso8601 }
    let!(:stub_clickhouse_query) do
      stub_request(:post, /#{ClickHouse.config.url}/).and_return(status: 200, body: clickhouse_response_body)
    end
    let(:query) do
      {
        'account-id': account.uuid,
        'from-time': from_time,
        sampling: 'minute'
      }
    end

    context 'when valid params' do
      it_behaves_like :responds_success
    end

    context 'without params' do
      let(:query) { {} }
      let(:stub_clickhouse_query) { nil }

      include_examples :responds_400, 'missing required param(s) account-id, from-time, sampling'
    end

    context 'with from-time in the future', freeze_time: Time.parse('2024-12-01 00:00:00 UTC') do
      let(:query) { super().merge 'from-time': '2024-12-25T05:00:00Z', 'to-time': '2024-12-26T05:00:00Z' }

      before { Log::ApiLog.add_partitions }

      it 'should NOT perform POST request to ClickHouse server and then return empty collection' do
        expect(CaptureError).not_to receive(:capture)
        subject

        expect(stub_clickhouse_query).not_to have_been_requested
        expect(response_json).to eq([])
      end
    end

    context 'when the "from-time" is invalid Date' do
      let(:query) { super().merge 'from-time': 'invalid' }

      include_examples :responds_400, 'invalid value from-time'
    end

    context 'when the "to-time" is invalid Date' do
      let(:query) { super().merge 'to-time': 'invalid' }

      include_examples :responds_400, 'invalid value to-time'
    end
  end
end
