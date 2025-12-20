# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::OutgoingActiveCallsController, type: :request do
  include_context :customer_out_active_calls_clickhouse_helpers
  include_context :json_api_customer_v1_helpers, type: :'outgoing-active-calls'
  let(:auth_headers) { { 'Authorization' => json_api_auth_token } }

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

  describe 'GET /api/rest/customer/v1/outgoing-active-calls' do
    subject do
      get '/api/rest/customer/v1/outgoing-active-calls', params: query, headers: auth_headers
    end

    let!(:accounts) { create_list :account, 2, contractor: customer }
    let(:account) { accounts.first }

    let(:query) do
      { 'account-id': account.uuid }
    end

    context 'with only required filters' do
      include_examples :responds_success
      include_examples :clickhouse_stub_requested
    end

    context 'with all filters' do
      let(:query) do
        super().merge(
          'auth-orig-ip': '10.20.30.40',
          'auth-orig-port': 8888,
          'auth-orig-transport-protocol-id': 1,
          'connect-time-null': 'true',
          'src-name-in-eq': 'qwe',
          'src-name-in-starts-with': 'q',
          'src-name-in-ends-with': 'e',
          'src-name-in-contains': 'w',
          'src-prefix-in-eq': '123',
          'src-prefix-in-starts-with': '1',
          'src-prefix-in-ends-with': '3',
          'src-prefix-in-contains': '2',
          'src-prefix-routing-eq': '456',
          'src-prefix-routing-starts-with': '4',
          'src-prefix-routing-ends-with': '6',
          'src-prefix-routing-contains': '5',
          'dst-prefix-in-eq': '789',
          'dst-prefix-in-starts-with': '7',
          'dst-prefix-in-ends-with': '9',
          'dst-prefix-in-contains': '8',
          'dst-prefix-routing-eq': '112233',
          'dst-prefix-routing-starts-with': '11',
          'dst-prefix-routing-ends-with': '33',
          'dst-prefix-routing-contains': '22'
        )
      end
      let(:clickhouse_query_sql_where_conditions) do
        [
          *super(),
          'auth_orig_ip = {auth_orig_ip: String}',
          'auth_orig_port = {auth_orig_port: Int32}',
          'auth_orig_transport_protocol_id = {auth_orig_transport_protocol_id: Int8}',
          'connect_time IS NULL',

          'src_name_in = {src_name_in_eq: String}',
          'startsWith(src_name_in, {src_name_in_starts_with: String})',
          'endsWith(src_name_in, {src_name_in_ends_with: String})',
          'positionCaseInsensitive(src_name_in, {src_name_in_contains: String}) > 0',

          'src_prefix_in = {src_prefix_in_eq: String}',
          'startsWith(src_prefix_in, {src_prefix_in_starts_with: String})',
          'endsWith(src_prefix_in, {src_prefix_in_ends_with: String})',
          'positionCaseInsensitive(src_prefix_in, {src_prefix_in_contains: String}) > 0',

          'src_prefix_routing = {src_prefix_routing_eq: String}',
          'startsWith(src_prefix_routing, {src_prefix_routing_starts_with: String})',
          'endsWith(src_prefix_routing, {src_prefix_routing_ends_with: String})',
          'positionCaseInsensitive(src_prefix_routing, {src_prefix_routing_contains: String}) > 0',

          'dst_prefix_in = {dst_prefix_in_eq: String}',
          'startsWith(dst_prefix_in, {dst_prefix_in_starts_with: String})',
          'endsWith(dst_prefix_in, {dst_prefix_in_ends_with: String})',
          'positionCaseInsensitive(dst_prefix_in, {dst_prefix_in_contains: String}) > 0',

          'dst_prefix_routing = {dst_prefix_routing_eq: String}',
          'startsWith(dst_prefix_routing, {dst_prefix_routing_starts_with: String})',
          'endsWith(dst_prefix_routing, {dst_prefix_routing_ends_with: String})',
          'positionCaseInsensitive(dst_prefix_routing, {dst_prefix_routing_contains: String}) > 0'
        ]
      end
      let(:clickhouse_query_params) do
        super().merge(
          param_auth_orig_ip: query[:'auth-orig-ip'],
          param_auth_orig_port: query[:'auth-orig-port'],
          param_auth_orig_transport_protocol_id: query[:'auth-orig-transport-protocol-id'],
          param_src_name_in_eq: query[:'src-name-in-eq'],
          param_src_name_in_starts_with: query[:'src-name-in-starts-with'],
          param_src_name_in_ends_with: query[:'src-name-in-ends-with'],
          param_src_name_in_contains: query[:'src-name-in-contains'],
          param_src_prefix_in_eq: query[:'src-prefix-in-eq'],
          param_src_prefix_in_starts_with: query[:'src-prefix-in-starts-with'],
          param_src_prefix_in_ends_with: query[:'src-prefix-in-ends-with'],
          param_src_prefix_in_contains: query[:'src-prefix-in-contains'],
          param_src_prefix_routing_eq: query[:'src-prefix-routing-eq'],
          param_src_prefix_routing_starts_with: query[:'src-prefix-routing-starts-with'],
          param_src_prefix_routing_ends_with: query[:'src-prefix-routing-ends-with'],
          param_src_prefix_routing_contains: query[:'src-prefix-routing-contains'],
          param_dst_prefix_in_eq: query[:'dst-prefix-in-eq'],
          param_dst_prefix_in_starts_with: query[:'dst-prefix-in-starts-with'],
          param_dst_prefix_in_ends_with: query[:'dst-prefix-in-ends-with'],
          param_dst_prefix_in_contains: query[:'dst-prefix-in-contains'],
          param_dst_prefix_routing_eq: query[:'dst-prefix-routing-eq'],
          param_dst_prefix_routing_starts_with: query[:'dst-prefix-routing-starts-with'],
          param_dst_prefix_routing_ends_with: query[:'dst-prefix-routing-ends-with'],
          param_dst_prefix_routing_contains: query[:'dst-prefix-routing-contains']
        )
      end

      include_examples :responds_success
      include_examples :clickhouse_stub_requested
    end

    context 'when api_access have filled account_ids' do
      let!(:accounts) { create_list(:account, 4, contractor: customer) }
      let(:allowed_accounts) { accounts.slice(0, 2) }
      let(:api_access_attrs) { super().merge account_ids: allowed_accounts.map(&:id) }

      context 'when filtered by allowed account_id' do
        include_examples :responds_success
        include_examples :clickhouse_stub_requested
      end

      context 'when filtered by not allowed account_id' do
        let(:query) do
          super().merge 'account-id': accounts.last.uuid
        end

        include_examples :clickhouse_stub_not_requested
        include_examples :responds_400, 'invalid value account-id'
      end
    end

    context 'with dynamic auth' do
      let(:auth_config) { { customer_id: customer.id } }
      let(:api_access) { nil }

      context 'with empty account_ids in token' do
        include_examples :responds_success
        include_examples :clickhouse_stub_requested
      end

      context 'with filled account_ids in token' do
        let!(:accounts) { create_list :account, 4, contractor: customer }
        let(:allowed_accounts) { accounts.slice(0, 2) }
        let(:auth_config) { super().merge account_ids: allowed_accounts.map(&:id) }

        context 'when filtered by allowed account_id' do
          include_examples :responds_success
          include_examples :clickhouse_stub_requested
        end

        context 'when filtered by not allowed account_id' do
          let(:query) do
            super().merge 'account-id': accounts.last.uuid
          end

          include_examples :clickhouse_stub_not_requested
          include_examples :responds_400, 'invalid value account-id'
        end
      end
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
