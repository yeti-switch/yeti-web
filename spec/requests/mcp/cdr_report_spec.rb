# frozen_string_literal: true

RSpec.describe 'MCP cdr_report tool', type: :request do
  include_context :with_oauth_routes

  let(:admin) { create(:admin_user) }
  let(:token) { issue_access_token(admin: admin) }

  let(:from) { '2026-06-13 00:00:00' }
  let(:to) { '2026-06-13 06:00:00' }

  def call_tool(arguments)
    mcp_call(
      token: token.plaintext_token,
      method: 'tools/call',
      params: { name: 'cdr_report', arguments: arguments }
    )
  end

  def result
    JSON.parse(response.body).fetch('result')
  end

  def error_text
    result.dig('content', 0, 'text')
  end

  # All of these fail in build_sql *before* any ClickHouse call, so no stub.
  describe 'input validation' do
    it 'requires at least one measure' do
      call_tool('from' => from, 'to' => to)
      expect(result['isError']).to be true
      expect(error_text).to match(/measure/i)
    end

    it 'rejects an unknown / injected measure name' do
      call_tool('measures' => ['calls; DROP TABLE cdrs'], 'from' => from, 'to' => to)
      expect(result['isError']).to be true
      expect(error_text).to match(/unknown measure/i)
    end

    it 'rejects a raw PII column as a dimension (reachable only via uniq measures)' do
      call_tool('measures' => ['calls'], 'dimensions' => ['src_prefix_in'], 'from' => from, 'to' => to)
      expect(result['isError']).to be true
      expect(error_text).to match(/unknown dimension/i)
    end

    it 'rejects a raw PII column as a filter field' do
      call_tool(
        'measures' => ['calls'],
        'filters' => [{ 'field' => 'sign_orig_ip', 'op' => 'eq', 'value' => '1.2.3.4' }],
        'from' => from, 'to' => to
      )
      expect(result['isError']).to be true
      expect(error_text).to match(/unknown filter field/i)
    end

    it 'rejects an unknown operator' do
      call_tool(
        'measures' => ['calls'],
        'filters' => [{ 'field' => 'internal_disconnect_code_id', 'op' => 'like', 'value' => 1 }],
        'from' => from, 'to' => to
      )
      expect(result['isError']).to be true
      expect(error_text).to match(/unknown operator/i)
    end

    it 'rejects an over-long time window' do
      call_tool('measures' => ['calls'], 'from' => '2026-01-01 00:00:00', 'to' => '2026-03-01 00:00:00')
      expect(result['isError']).to be true
      expect(error_text).to match(/window exceeds/i)
    end

    it 'rejects from >= to' do
      call_tool('measures' => ['calls'], 'from' => to, 'to' => from)
      expect(result['isError']).to be true
      expect(error_text).to match(/before/i)
    end

    it 'requires the time window' do
      call_tool('measures' => ['calls'])
      expect(result['isError']).to be true
      expect(error_text).to match(/from.*required/i)
    end
  end

  describe 'happy path' do
    let(:ch_connection) { double('ClickHouse.connection') }
    let(:ch_response) do
      double(
        'ch_response',
        status: 200,
        body: {
          'rows' => 1,
          'data' => [{ 'internal_disconnect_code_id' => 5, 'calls' => 100, 'distinct_src_numbers' => 1 }]
        }
      )
    end

    before do
      allow(ClickHouse).to receive(:connection).and_return(ch_connection)
      allow(ch_connection).to receive(:execute).and_return(ch_response)
    end

    it 'returns the aggregated rows' do
      call_tool(
        'measures' => %w[calls distinct_src_numbers],
        'dimensions' => ['internal_disconnect_code_id'],
        'filters' => [{ 'field' => 'dst_country_id', 'op' => 'in', 'value' => [1, 7] }],
        'from' => from, 'to' => to
      )
      expect(result['isError']).to be_falsey
      payload = JSON.parse(error_text)
      expect(payload['rows']).to eq(1)
      expect(payload['data'].first).to include('internal_disconnect_code_id' => 5, 'distinct_src_numbers' => 1)
    end

    it 'binds values as params instead of interpolating them, and pins the window to UTC' do
      captured = {}
      allow(ch_connection).to receive(:execute) do |sql, _body, params:|
        captured[:sql] = sql
        captured[:params] = params
        ch_response
      end

      call_tool(
        'measures' => %w[calls distinct_src_numbers],
        'dimensions' => %w[internal_disconnect_code_id hour],
        'filters' => [{ 'field' => 'internal_disconnect_code_id', 'op' => 'eq', 'value' => 42 }],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      # measure/dimension fragments come from server-side constants
      expect(captured[:sql]).to include('uniq(src_prefix_in) AS distinct_src_numbers')
      expect(captured[:sql]).to include('toStartOfHour(time_start) AS hour')
      # window is parsed as UTC in SQL regardless of server timezone
      expect(captured[:sql]).to include("toDateTime({from: String}, 'UTC')")
      # the filter value is bound, never written into the SQL text
      expect(captured[:sql]).not_to include('42')
      expect(captured[:params]).to include(
        'param_from' => '2026-06-13 00:00:00',
        'param_to' => '2026-06-13 06:00:00'
      )
      expect(captured[:params].values).to include(42)
    end

    it 'caps the row limit at MAX_LIMIT' do
      allow(ch_connection).to receive(:execute).and_return(ch_response)
      call_tool('measures' => ['calls'], 'from' => from, 'to' => to, 'limit' => 999_999)
      expect(ch_connection).to have_received(:execute) do |sql, *_|
        expect(sql).to include("LIMIT #{Mcp::Tools::CdrReport::MAX_LIMIT}")
      end
    end

    it 'on a non-200 ClickHouse response returns a generic error and logs the real cause' do
      allow(ch_connection).to receive(:execute)
        .and_return(double(status: 404, body: { 'exception' => 'Code: 60. DB::Exception: Unknown table' }))
      expect(Rails.logger).to receive(:error).with(/HTTP 404.*Code: 60.*Unknown table/m)

      call_tool('measures' => ['calls'], 'from' => from, 'to' => to)

      expect(result['isError']).to be true
      expect(error_text).to eq('Internal server error')
      # nothing internal leaks to the client
      expect(error_text).not_to match(/404|DB::Exception|Code:/)
    end

    it 'treats a 200 response carrying an "exception" attribute as a failure' do
      allow(ch_connection).to receive(:execute)
        .and_return(double(status: 200, body: { 'exception' => 'Code: 159. DB::Exception: Timeout exceeded' }))
      expect(Rails.logger).to receive(:error).with(/Timeout exceeded/)

      call_tool('measures' => ['calls'], 'from' => from, 'to' => to)

      expect(result['isError']).to be true
      expect(error_text).to eq('Internal server error')
    end

    it 'on a ClickHouse/transport exception returns a generic error and logs it' do
      allow(ch_connection).to receive(:execute).and_raise(StandardError.new('connection refused'))
      expect(Rails.logger).to receive(:error).with(/StandardError.*connection refused/m)

      call_tool('measures' => ['calls'], 'from' => from, 'to' => to)

      expect(result['isError']).to be true
      expect(error_text).to eq('Internal server error')
    end
  end

  shared_context :with_captured_query do
    let(:ch_connection) { double('ClickHouse.connection') }
    let(:ch_rows) { [] }
    let(:ch_response) { double('ch_response', status: 200, body: { 'rows' => ch_rows.size, 'data' => ch_rows }) }
    let(:captured) { {} }

    before do
      allow(ClickHouse).to receive(:connection).and_return(ch_connection)
      allow(ch_connection).to receive(:execute) do |sql, _body, params:|
        captured[:sql] = sql
        captured[:params] = params
        ch_response
      end
    end
  end

  describe 'filters and operators' do
    include_context :with_captured_query

    # Regression: a Ruby Array encoded as `param_f1[]=1&param_f1[]=7`, which
    # ClickHouse cannot parse as Array(Int32) — every in/not_in filter 500'd.
    it 'binds in/not_in as a ClickHouse array literal, not a Ruby array' do
      call_tool(
        'measures' => ['calls'],
        'filters' => [{ 'field' => 'dst_country_id', 'op' => 'in', 'value' => [1, 7] }],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(captured[:sql]).to include('dst_country_id IN {f1: Array(Int32)}')
      expect(captured[:params]['param_f1']).to eq('[1,7]')
    end

    it 'escapes quotes and backslashes inside a String array literal' do
      call_tool(
        'measures' => ['calls'],
        'filters' => [{ 'field' => 'internal_disconnect_reason', 'op' => 'in',
                        'value' => ['CPS limit', "O'Brien"] }],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(captured[:params]['param_f1']).to eq("['CPS limit','O\\'Brien']")
    end

    it 'matches a user agent by case-insensitive substring, with the value bound' do
      call_tool(
        'measures' => ['calls'],
        'filters' => [{ 'field' => 'lega_user_agent', 'op' => 'contains', 'value' => 'Asterisk' }],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(captured[:sql]).to include('positionCaseInsensitive(lega_user_agent, {f1: String}) > 0')
      expect(captured[:sql]).not_to include('Asterisk')
      expect(captured[:params]['param_f1']).to eq('Asterisk')
    end

    it 'rejects contains on a numeric field' do
      call_tool(
        'measures' => ['calls'],
        'filters' => [{ 'field' => 'internal_disconnect_code_id', 'op' => 'contains', 'value' => 'Asterisk' }],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be true
      expect(error_text).to match(/text fields only/i)
    end
  end

  describe 'dimensions and measures' do
    include_context :with_captured_query

    it 'groups by src/dst network type' do
      call_tool(
        'measures' => ['calls'], 'dimensions' => %w[dst_network_type_id src_network_type_id],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(captured[:sql]).to include('dst_network_type_id AS dst_network_type_id')
      expect(captured[:sql]).to include('GROUP BY dst_network_type_id, src_network_type_id')
    end

    it 'emits pdd/rtt/acd percentile aggregates' do
      call_tool('measures' => %w[pdd_p95 rtt_p99 acd_p50], 'from' => from, 'to' => to)

      expect(result['isError']).to be_falsey
      expect(captured[:sql]).to include('round(quantileIf(0.95)(pdd, pdd > 0), 3) AS pdd_p95')
      expect(captured[:sql]).to include('round(quantileIf(0.99)(rtt, rtt > 0), 3) AS rtt_p99')
      expect(captured[:sql]).to include('round(quantileIf(0.5)(duration, success = 1), 1) AS acd_p50')
    end

    it 'binds the short-call threshold, defaulting to SHORT_CALL_DEFAULT_SECONDS' do
      call_tool('measures' => %w[short_calls short_calls_ratio], 'from' => from, 'to' => to)

      expect(result['isError']).to be_falsey
      expect(captured[:sql]).to include('duration <= {short_call_seconds: UInt16}')
      expect(captured[:params]['param_short_call_seconds'])
        .to eq(Mcp::Tools::CdrReport::SHORT_CALL_DEFAULT_SECONDS)
    end

    it 'honours a caller-supplied short_call_seconds' do
      call_tool(
        'measures' => ['short_calls_ratio'], 'short_call_seconds' => 30,
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(captured[:params]['param_short_call_seconds']).to eq(30)
    end

    it 'does not bind the threshold when no short-call measure is selected' do
      call_tool('measures' => ['calls'], 'from' => from, 'to' => to)

      expect(result['isError']).to be_falsey
      expect(captured[:params]).not_to have_key('param_short_call_seconds')
    end
  end

  describe 'contractor uuids' do
    include_context :with_captured_query

    let!(:customer) { create(:customer, name: 'Acme Telecom') }
    let(:ch_rows) { [{ 'customer_uuid' => customer.id, 'calls' => 10 }] }

    def rows
      JSON.parse(error_text)['data']
    end

    it 'selects the contractor id but returns only its uuid' do
      call_tool('measures' => ['calls'], 'dimensions' => ['customer_uuid'], 'from' => from, 'to' => to)

      expect(result['isError']).to be_falsey
      expect(captured[:sql]).to include('customer_id AS customer_uuid')
      expect(rows.first).to eq('customer_uuid' => customer.uuid, 'calls' => 10)
      expect(error_text).not_to include(customer.id.to_s)
    end

    it 'has no dimension or filter for the raw contractor id' do
      %w[customer_id vendor_id].each do |field|
        call_tool('measures' => ['calls'], 'dimensions' => [field], 'from' => from, 'to' => to)
        expect(error_text).to match(/unknown dimension/i)

        call_tool(
          'measures' => ['calls'],
          'filters' => [{ 'field' => field, 'op' => 'eq', 'value' => 1 }],
          'from' => from, 'to' => to
        )
        expect(error_text).to match(/unknown filter field/i)
      end
    end

    it 'filters by uuid, binding the resolved id' do
      call_tool(
        'measures' => ['calls'],
        'filters' => [{ 'field' => 'customer_uuid', 'op' => 'eq', 'value' => customer.uuid }],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(captured[:sql]).to include('customer_id = {f1: Int32}')
      expect(captured[:params]['param_f1']).to eq(customer.id)
    end

    it 'filters by a list of uuids' do
      other = create(:customer)
      call_tool(
        'measures' => ['calls'],
        'filters' => [{ 'field' => 'customer_uuid', 'op' => 'in',
                        'value' => [customer.uuid, other.uuid] }],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(captured[:params]['param_f1']).to eq("[#{customer.id},#{other.id}]")
    end

    # Otherwise the filter is an enumeration oracle.
    it 'rejects a bare id in a uuid filter' do
      [customer.id, customer.id.to_s, 'not-a-uuid'].each do |value|
        call_tool(
          'measures' => ['calls'],
          'filters' => [{ 'field' => 'customer_uuid', 'op' => 'eq', 'value' => value }],
          'from' => from, 'to' => to
        )

        expect(result['isError']).to be true
        expect(error_text).to match(/expected a uuid/i)
      end
    end

    # A well-formed uuid nobody holds must not answer "does this exist?".
    it 'binds a non-matching id for an unknown uuid rather than erroring' do
      call_tool(
        'measures' => ['calls'],
        'filters' => [{ 'field' => 'customer_uuid', 'op' => 'eq', 'value' => SecureRandom.uuid }],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(captured[:params]['param_f1']).to eq(0)
    end

    it 'refuses to sort by a uuid' do
      call_tool(
        'measures' => ['calls'], 'dimensions' => ['customer_uuid'],
        'order_by' => { 'field' => 'customer_uuid' }, 'from' => from, 'to' => to
      )

      expect(result['isError']).to be true
      expect(error_text).to match(/not sortable/i)
    end

    it 'still emits a uuid when name resolution is off' do
      call_tool(
        'measures' => ['calls'], 'dimensions' => ['customer_uuid'],
        'resolve_names' => false, 'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(rows.first).to include('customer_uuid' => customer.uuid)
    end

    # ClickHouse renders 64-bit ints as quoted strings.
    it 'resolves a contractor id that arrives as a quoted integer' do
      allow(ch_response).to receive(:body).and_return(
        { 'rows' => 1, 'data' => [{ 'customer_uuid' => customer.id.to_s, 'calls' => 1 }] }
      )
      call_tool('measures' => ['calls'], 'dimensions' => ['customer_uuid'], 'from' => from, 'to' => to)

      expect(result['isError']).to be_falsey
      expect(rows.first['customer_uuid']).to eq(customer.uuid)
    end

    it 'resolves the whole page in one query' do
      others = create_list(:customer, 3)
      allow(ch_response).to receive(:body).and_return(
        { 'rows' => 4, 'data' => ([customer] + others).map { |c| { 'customer_uuid' => c.id, 'calls' => 1 } } }
      )

      expect(Contractor).to receive(:where).once.and_call_original
      call_tool('measures' => ['calls'], 'dimensions' => ['customer_uuid'], 'from' => from, 'to' => to)

      expect(rows.map { |r| r['customer_uuid'] }).to match_array(([customer] + others).map(&:uuid))
    end

    it 'returns account references as uuids too' do
      account = create(:account)
      allow(ch_response).to receive(:body).and_return(
        { 'rows' => 1,
          'data' => [{ 'customer_uuid' => customer.id, 'customer_acc_uuid' => account.id, 'calls' => 1 }] }
      )
      call_tool(
        'measures' => ['calls'], 'dimensions' => %w[customer_uuid customer_acc_uuid],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(captured[:sql]).to include('customer_acc_id AS customer_acc_uuid')
      expect(rows.first).to include(
        'customer_uuid' => customer.uuid,
        'customer_acc_uuid' => account.uuid
      )
    end

    it 'filters by account uuid, binding the resolved account id' do
      account = create(:account)
      call_tool(
        'measures' => ['calls'],
        'filters' => [{ 'field' => 'customer_acc_uuid', 'op' => 'eq', 'value' => account.uuid }],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(captured[:sql]).to include('customer_acc_id = {f1: Int32}')
      expect(captured[:params]['param_f1']).to eq(account.id)
    end

    it 'has no dimension or filter for the raw account or gateway id' do
      %w[customer_acc_id vendor_acc_id orig_gw_id term_gw_id].each do |field|
        call_tool('measures' => ['calls'], 'dimensions' => [field], 'from' => from, 'to' => to)
        expect(error_text).to match(/unknown dimension/i)
      end
    end

    it 'returns gateway references as uuids' do
      gateway = create(:gateway)
      allow(ch_response).to receive(:body).and_return(
        { 'rows' => 1, 'data' => [{ 'term_gw_uuid' => gateway.id, 'calls' => 1 }] }
      )
      call_tool('measures' => ['calls'], 'dimensions' => ['term_gw_uuid'], 'from' => from, 'to' => to)

      expect(result['isError']).to be_falsey
      expect(captured[:sql]).to include('term_gw_id AS term_gw_uuid')
      expect(rows.first).to eq('term_gw_uuid' => gateway.uuid, 'calls' => 1)
    end

    it 'filters by gateway uuid, binding the resolved gateway id' do
      gateway = create(:gateway)
      call_tool(
        'measures' => ['calls'],
        'filters' => [{ 'field' => 'term_gw_uuid', 'op' => 'eq', 'value' => gateway.uuid }],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(captured[:sql]).to include('term_gw_id = {f1: Int32}')
      expect(captured[:params]['param_f1']).to eq(gateway.id)
    end

    # Contractors and accounts are looked up separately; neither is per-row.
    it 'uses one lookup per referenced model, not per dimension or row' do
      accounts = create_list(:account, 3)
      allow(ch_response).to receive(:body).and_return(
        { 'rows' => 3,
          'data' => accounts.map { |a| { 'customer_uuid' => customer.id, 'customer_acc_uuid' => a.id, 'calls' => 1 } } }
      )

      expect(Contractor).to receive(:where).once.and_call_original
      expect(Account).to receive(:where).once.and_call_original

      call_tool(
        'measures' => ['calls'], 'dimensions' => %w[customer_uuid customer_acc_uuid],
        'from' => from, 'to' => to
      )
      expect(result['isError']).to be_falsey
    end

    it 'yields nil rather than failing on a value that cannot be a contractor id' do
      allow(ch_response).to receive(:body).and_return(
        { 'rows' => 2, 'data' => [{ 'customer_uuid' => nil, 'calls' => 1 },
                                  { 'customer_uuid' => 0, 'calls' => 2 }] }
      )
      call_tool('measures' => ['calls'], 'dimensions' => ['customer_uuid'], 'from' => from, 'to' => to)

      expect(result['isError']).to be_falsey
      expect(rows.map { |r| r['customer_uuid'] }).to eq([nil, nil])
    end
  end

  describe 'name resolution' do
    include_context :with_captured_query

    let!(:country) { create(:country, name: 'Neverland') }
    let!(:network_type) { create(:network_type) }
    let!(:customer) { create(:customer, name: 'Acme Telecom') }
    let(:ch_rows) do
      [{ 'customer_uuid' => customer.id, 'dst_country_id' => country.id,
         'dst_network_type_id' => network_type.id, 'calls' => 10 }]
    end

    def rows
      JSON.parse(error_text)['data']
    end

    it 'returns each reference id with its display name directly after it' do
      call_tool(
        'measures' => ['calls'], 'dimensions' => %w[dst_country_id dst_network_type_id],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(rows.first).to include(
        'dst_country_name' => 'Neverland',
        'dst_network_type_name' => network_type.name
      )
    end

    it 'never names a counterparty, even when grouped by it' do
      call_tool(
        'measures' => ['calls'], 'dimensions' => %w[customer_uuid dst_country_id],
        'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(rows.first).not_to have_key('customer_name')
      expect(error_text).not_to include('Acme Telecom')
      # ...while the non-identifying reference name is still resolved
      expect(rows.first).to include('dst_country_name' => 'Neverland')
    end

    it 'has no dictionary for counterparty or prefix-valued dimensions' do
      forbidden = %w[
        customer_uuid vendor_uuid customer_acc_uuid vendor_acc_uuid
        orig_gw_uuid term_gw_uuid rateplan_id destination_id dialpeer_id
      ]

      expect(Mcp::Tools::CdrReport::DICTIONARIES.keys & forbidden).to be_empty
    end

    it 'skips resolution when resolve_names is false' do
      call_tool(
        'measures' => ['calls'], 'dimensions' => ['dst_country_id'],
        'resolve_names' => false, 'from' => from, 'to' => to
      )

      expect(result['isError']).to be_falsey
      expect(rows.first).not_to have_key('dst_country_name')
    end

    it 'still returns the report when a reference lookup blows up' do
      allow(System::Country).to receive(:where).and_raise(ActiveRecord::StatementInvalid, 'boom')
      expect(Rails.logger).to receive(:error).with(/name resolution failed/)

      call_tool('measures' => ['calls'], 'dimensions' => ['dst_country_id'], 'from' => from, 'to' => to)

      expect(result['isError']).to be_falsey
      expect(rows.first).to include('calls' => 10)
    end
  end
end
