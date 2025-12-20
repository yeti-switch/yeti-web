# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::OriginationStatisticsQualityController, type: :request do
  include_context :customer_origination_statistics_quality_clickhouse_helpers
  include_context :json_api_customer_v1_helpers, type: :accounts

  let(:auth_headers) { { 'Authorization' => json_api_auth_token } }

  before do
    # Accounts not belongs to current customer
    create_list :account, 1
  end

  describe 'GET /api/rest/customer/v1/origination-statistics-quality' do
    subject do
      get '/api/rest/customer/v1/origination-statistics-quality', params: query, headers: auth_headers
    end

    shared_examples :responds_400 do |error_message|
      it 'responds with correct data' do
        expect(CaptureError).not_to receive(:capture)
        subject
        expect(response.status).to eq 400
        expect(response_json).to eq(error: error_message)
      end
    end

    shared_examples :responds_success do
      let(:expected_response_data) { clickhouse_response_body.slice(:data, :rows, :totals) }

      it 'responds with correct data' do
        expect(CaptureError).not_to receive(:capture)
        subject

        expect(response.status).to eq 200
        expect(response_json).to eq expected_response_data
      end
    end

    let!(:account) { create(:account, contractor: customer) }
    let(:query) do
      {
        'account-id': account.uuid,
        'from-time': 1.day.ago.iso8601,
        sampling: 'minute'
      }
    end

    context 'with only required params' do
      include_examples :responds_success
      include_examples :clickhouse_stub_requested
    end

    context 'when account from account_ids' do
      before { api_access.update! account_ids: [account.id] }

      include_examples :responds_success
      include_examples :clickhouse_stub_requested
    end

    context 'with all allowed params' do
      let(:query) do
        super().merge(
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
          'auth-orig-ip': '192.168.1.1',
          'customer-price-eq': '5.55',
          'customer-price-gt': '5.54',
          'customer-price-lt': '5.56',
          sampling: 'minute'
        )
      end
      let(:clickhouse_query_sql_where_conditions) do
        [
          *super(),
          'time_start <= {to_time: DateTime}',
          'src_country_id = {src_country_id: UInt32}',
          'dst_country_id = {dst_country_id: UInt32}',
          'src_prefix_routing = {src_prefix_routing_eq: String}',
          'startsWith(src_prefix_routing, {src_prefix_routing_starts_with: String})',
          'endsWith(src_prefix_routing, {src_prefix_routing_ends_with: String})',
          'positionCaseInsensitive(src_prefix_routing, {src_prefix_routing_contains: String}) > 0',
          'dst_prefix_routing = {dst_prefix_routing_eq: String}',
          'startsWith(dst_prefix_routing, {dst_prefix_routing_starts_with: String})',
          'endsWith(dst_prefix_routing, {dst_prefix_routing_ends_with: String})',
          'positionCaseInsensitive(dst_prefix_routing, {dst_prefix_routing_contains: String}) > 0',
          'duration = {duration_eq: Int32}',
          'duration > {duration_gt: Int32}',
          'duration < {duration_lt: Int32}',
          'auth_orig_ip = {auth_orig_ip: String}',
          'customer_price = {customer_price_eq: Float64}',
          'customer_price > {customer_price_gt: Float64}',
          'customer_price < {customer_price_lt: Float64}'
        ]
      end
      let(:clickhouse_query_params) do
        super().merge(
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
        )
      end

      include_examples :responds_success
      include_examples :clickhouse_stub_requested
    end

    context 'without params' do
      let(:query) { nil }
      let(:clickhouse_query_params) { {} }

      include_examples :responds_400, 'missing required param(s) account-id, from-time, sampling'
      include_examples :clickhouse_stub_not_requested
    end

    context 'with not allowed account-id' do
      before do
        another_account = create(:account, contractor: customer)
        api_access.update!(account_ids: [another_account.id])
      end

      include_examples :responds_400, 'invalid value account-id'
      include_examples :clickhouse_stub_not_requested
    end

    context 'with account-id from different customer' do
      let(:query) { super().merge 'account-id': another_account.uuid }
      let!(:another_customer) { create(:api_access).customer }
      let!(:another_account) { create(:account, contractor: another_customer) }

      include_examples :responds_400, 'invalid value account-id'
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
