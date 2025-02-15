# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::TerminationActiveCallsController do
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
      it 'responds with correct data' do
        expect(CaptureError).not_to receive(:capture)
        subject

        expect(response.status).to eq 200
        expect(response_json).to eq active_calls_response_body
      end
    end

    let!(:account) { create(:account, contractor: customer) }
    let(:clickhouse_query) do
      <<-SQL.squish
        SELECT
          toUnixTimestamp(snapshot_timestamp) as t,
          toUInt32(count(*)) AS calls
        FROM active_calls
        WHERE
          vendor_acc_id = {account_id: UInt32} AND
          snapshot_timestamp >= {from_time: DateTime}
        GROUP BY t
        ORDER BY t
        WITH FILL
          FROM toUnixTimestamp(toStartOfMinute({from_time: DateTime}))
          TO toUnixTimestamp(now())
          STEP 60
        FORMAT JSONColumnsWithMetadata
      SQL
    end
    let(:clickhouse_params) do
      {
        param_account_id: account.id,
        param_from_time: from_time
      }
    end
    let!(:stub_clickhouse_query) do
      stub_request(:post, ClickHouse.config.url)
        .with(
          basic_auth: [ClickHouse.config.username, ClickHouse.config.password],
          query: {
            database: ClickHouse.config.database,
            **clickhouse_params,
            query: clickhouse_query,
            send_progress_in_http_headers: 1
          }
        ).to_return(
        status: active_calls_response_status,
        body: active_calls_response_body.to_json
      )
    end
    let(:active_calls_response_status) { 200 }
    let(:active_calls_response_body) { [{ call_id: 'abc123', duration: 123 }] }
    let(:from_time) { 1.day.ago.iso8601 }
    let(:query) do
      {
        'account-id': account.uuid,
        'from-time': from_time
      }
    end

    it_behaves_like :responds_success

    context 'without params' do
      let(:query) { nil }
      let(:stub_clickhouse_query) { nil }

      include_examples :responds_400, 'missing required param(s) account-id, from-time'
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
