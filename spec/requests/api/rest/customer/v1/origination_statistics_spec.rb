# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::OriginationStatisticsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :accounts
  let(:auth_headers) do
    { 'Authorization' => json_api_auth_token }
  end

  before do
    # Accounts not belongs to current customer
    create_list :account, 1
  end

  describe 'GET /api/rest/customer/v1/origination-statistics' do
    subject do
      get '/api/rest/customer/v1/origination-statistics', params: query, headers: auth_headers
    end

    shared_examples :responds_400 do |error_message|
      include_examples :responds_with_status, 400

      it 'responds with correct data' do
        expect(CaptureError).not_to receive(:capture)
        subject
        expect(response_json).to eq(error: error_message)
      end
    end

    shared_examples :responds_success do
      include_examples :responds_with_status, 200

      it 'responds with correct data' do
        expect(CaptureError).not_to receive(:capture)
        subject
        expect(response_json).to eq(clickhouse_response_body)
      end
    end

    let!(:account) { create(:account, contractor: customer) }
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
        status: clickhouse_response_status,
        body: clickhouse_response_body.to_json
      )
    end
    let(:clickhouse_response_status) { 200 }
    let(:clickhouse_response_body) { [{ foo: 'bar' }, { foo: 'baz' }] } # returns clickhouse response body as is.
    let(:query) do
      {
        'account-id': account.uuid,
        'from-time': 1.day.ago.iso8601,
        sampling: 'minute'
      }
    end
    let(:clickhouse_query) do
      "
          SELECT
            toUnixTimestamp(toStartOfMinute(time_start)) as t,
            toUInt32(count(*)) AS total_calls,
            toUInt32(countIf(duration>0)) as successful_calls,
            toUInt32(countIf(duration=0)) as failed_calls,
            round(sum(duration)/60,2) as total_duration,
            round(avgIf(duration, duration>0)/60,2) AS acd,
            round(countIf(duration>0)/count(*),3)*100 AS asr,
            round(sum(customer_price),2) as total_price
          FROM cdrs
          WHERE customer_acc_id = {account_id: UInt32}
            AND time_start >= {from_time: DateTime}
            AND is_last_cdr = true
          GROUP BY t
          WITH TOTALS
          ORDER BY t
          FORMAT JSONColumnsWithMetadata
        ".squish
    end
    let(:clickhouse_params) do
      {
        param_account_id: account.id,
        param_from_time: query[:'from-time']
      }
    end

    # with only required params
    include_examples :responds_success

    context 'when account from account_ids' do
      before { api_access.update! account_ids: [account.id] }

      include_examples :responds_success
    end

    context 'with all allowed params' do
      let(:query) do
        {
          'account-id': account.uuid,
          'from-time': 1.day.ago.iso8601,
          'to-time': 1.minute.ago.iso8601,
          'src-country-id': 123,
          'dst-country-id': 456,
          'src-prefix-routing-eq': '111',
          'src-prefix-routing-starts-with': '112',
          'src-prefix-routing-ends-with': '113',
          'src-prefix-routing-contains': '114',
          'dst-prefix-routing-eq': '211',
          'dst-prefix-routing-starts-with': '212',
          'dst-prefix-routing-ends-with': '213',
          'dst-prefix-routing-contains': '214',
          'duration-eq': 10,
          'duration-gt': 9,
          'duration-lt': 11,
          'auth-orig-ip': '192.168.11.22',
          'customer-price-eq': '5.55',
          'customer-price-gt': '5.54',
          'customer-price-lt': '5.56',
          sampling: 'minute'
        }
      end

      before { stub_clickhouse_query }
      let(:clickhouse_query) do
        "
          SELECT
            toUnixTimestamp(toStartOfMinute(time_start)) as t,
            toUInt32(count(*)) AS total_calls,
            toUInt32(countIf(duration>0)) as successful_calls,
            toUInt32(countIf(duration=0)) as failed_calls,
            round(sum(duration)/60,2) as total_duration,
            round(avgIf(duration, duration>0)/60,2) AS acd,
            round(countIf(duration>0)/count(*),3)*100 AS asr,
            round(sum(customer_price),2) as total_price
          FROM cdrs
          WHERE customer_acc_id = {account_id: UInt32}
            AND time_start >= {from_time: DateTime}
            AND time_start <= {to_time: DateTime}
            AND src_country_id = {src_country_id: UInt32}
            AND dst_country_id = {dst_country_id: UInt32}
            AND src_prefix_routing = {src_prefix_routing_eq: String}
            AND startsWith(src_prefix_routing, {src_prefix_routing_starts_with: String})
            AND endsWith(src_prefix_routing, {src_prefix_routing_ends_with: String})
            AND positionCaseInsensitive(src_prefix_routing, {src_prefix_routing_contains: String}) > 0
            AND dst_prefix_routing = {dst_prefix_routing_eq: String}
            AND startsWith(dst_prefix_routing, {dst_prefix_routing_starts_with: String})
            AND endsWith(dst_prefix_routing, {dst_prefix_routing_ends_with: String})
            AND positionCaseInsensitive(dst_prefix_routing, {dst_prefix_routing_contains: String}) > 0
            AND duration = {duration_eq: Int32}
            AND duration > {duration_gt: Int32}
            AND duration < {duration_lt: Int32}
            AND auth_orig_ip = {auth_orig_ip: String}
            AND customer_price = {customer_price_eq: Float64}
            AND customer_price > {customer_price_gt: Float64}
            AND customer_price < {customer_price_lt: Float64}
            AND is_last_cdr = true
          GROUP BY t
          WITH TOTALS
          ORDER BY t
          FORMAT JSONColumnsWithMetadata
        ".squish
      end
      let(:clickhouse_params) do
        {
          param_account_id: account.id,
          param_from_time: query[:'from-time'],
          param_to_time: query[:'to-time'],
          param_src_country_id: query[:'src-country-id'],
          param_dst_country_id: query[:'dst-country-id'],
          param_src_prefix_routing_eq: query[:'src-prefix-routing-eq'],
          param_src_prefix_routing_starts_with: query[:'src-prefix-routing-starts-with'],
          param_src_prefix_routing_ends_with: query[:'src-prefix-routing-ends-with'],
          param_src_prefix_routing_contains: query[:'src-prefix-routing-contains'],
          param_dst_prefix_routing_eq: query[:'dst-prefix-routing-eq'],
          param_dst_prefix_routing_starts_with: query[:'dst-prefix-routing-starts-with'],
          param_dst_prefix_routing_ends_with: query[:'dst-prefix-routing-ends-with'],
          param_dst_prefix_routing_contains: query[:'dst-prefix-routing-contains'],
          param_duration_eq: query[:'duration-eq'],
          param_duration_gt: query[:'duration-gt'],
          param_duration_lt: query[:'duration-lt'],
          param_auth_orig_ip: query[:'auth-orig-ip'],
          param_customer_price_eq: query[:'customer-price-eq'],
          param_customer_price_gt: query[:'customer-price-gt'],
          param_customer_price_lt: query[:'customer-price-lt']
        }
      end

      include_examples :responds_success
    end

    context 'without params' do
      let(:query) { nil }
      let(:stub_clickhouse_query) { nil }

      include_examples :responds_400, 'missing required param(s) account-id, from-time, sampling'
    end

    context 'with not allowed account-id' do
      let(:stub_clickhouse_query) { nil }

      before do
        another_account = create(:account, contractor: customer)
        api_access.update!(account_ids: [another_account.id])
      end

      include_examples :responds_400, 'invalid value account-id'
    end

    context 'with account-id from different customer' do
      let(:stub_clickhouse_query) { nil }
      let(:query) { super().merge 'account-id': another_account.id }

      let!(:another_customer) { create(:api_access).customer }
      let!(:another_account) { create(:account, contractor: another_customer) }

      include_examples :responds_400, 'invalid value account-id'
    end

    context 'when clickhouse query fails' do
      let(:clickhouse_response_status) { 400 }
      let(:clickhouse_response_body) do
        {
          error: { code: 999, text: 'Some error', version: '1.1.1.11111' }
        }
      end

      it 'captures exception' do
        expect(CaptureError).to receive(:capture).with(
          a_kind_of(ClickHouse::Error), a_kind_of(Hash)
        ).once
        subject
      end

      include_examples :responds_with_status, 500, without_body: true
    end

    context 'with invalid Authorization header' do
      let(:stub_clickhouse_query) { nil }
      let(:json_api_auth_token) { 'invalid' }

      include_examples :responds_with_status, 401
    end
  end
end
