# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::TerminationActiveCallsController do
  include_context :customer_termination_active_calls_clickhouse_helpers
  include_context :json_api_customer_v1_helpers, type: :accounts

  let(:auth_headers) { { 'Authorization' => json_api_auth_token } }

  describe 'GET /api/rest/customer/v1/termination-active-calls' do
    subject { get '/api/rest/customer/v1/termination-active-calls', params: query, headers: auth_headers }

    shared_examples :responds_400 do |error_message|
      it 'responds with correct error data' do
        expect(CaptureError).not_to receive(:capture)
        subject

        expect(response.status).to eq 400
        expect(response_json).to eq error: error_message
      end
    end

    shared_examples :responds_success do
      let(:expected_response_data) { clickhouse_response_body.slice(:data, :rows) }

      it 'responds with correct data' do
        expect(CaptureError).not_to receive(:capture)
        subject

        expect(response.status).to eq 200
        expect(response_json).to eq expected_response_data
      end
    end

    let!(:account) { create(:account, contractor: customer) }
    let(:from_time) { 1.day.ago.iso8601 }
    let(:query) do
      {
        'account-id': account.uuid,
        'from-time': from_time
      }
    end

    include_examples :responds_success
    include_examples :clickhouse_stub_requested

    context 'without params' do
      let(:query) { nil }
      let(:stub_clickhouse_query) { nil }

      include_examples :responds_400, 'missing required param(s) account-id, from-time'
      include_examples :clickhouse_stub_not_requested
    end

    context 'with from-time in the future', freeze_time: Time.parse('2024-12-01 00:00:00 UTC') do
      let(:query) { super().merge 'from-time': '2024-12-25T05:00:00Z', 'to-time': '2024-12-26T05:00:00Z' }

      before { Log::ApiLog.add_partitions }

      include_examples :clickhouse_stub_not_requested
      include_examples :responds_success do
        let(:expected_response_data) { [] }
      end
    end

    context 'when the "from-time" is invalid Date' do
      let(:query) { super().merge 'from-time': 'invalid' }

      include_examples :responds_400, 'invalid value from-time'
      include_examples :clickhouse_stub_not_requested
    end

    context 'when the "to-time" is invalid Date' do
      let(:query) { super().merge 'to-time': 'invalid' }

      include_examples :responds_400, 'invalid value to-time'
      include_examples :clickhouse_stub_not_requested
    end

    context 'when clickhouse query fails' do
      let(:clickhouse_response_status) { 400 }
      let(:clickhouse_response_body) do
        { error: { code: 999, text: 'Some error', version: '1.1.1.11111' } }
      end

      include_examples :captures_error do
        let(:capture_error_exception_class) { ClickHouse::DbException }
        let(:capture_error_tags) { nil }
      end
      include_examples :responds_with_status, 500, without_body: true
      include_examples :clickhouse_stub_requested
    end

    context 'with invalid Authorization header' do
      let(:json_api_auth_token) { 'invalid' }

      include_examples :responds_with_status, 401
      include_examples :clickhouse_stub_not_requested
    end
  end
end
