# frozen_string_literal: true

RSpec.describe 'MCP cdr.report tool', type: :request do
  include_context :with_oauth_routes

  let(:admin) { create(:admin_user) }
  let(:token) { issue_access_token(admin: admin) }

  let(:from) { '2026-06-13 00:00:00' }
  let(:to) { '2026-06-13 06:00:00' }

  def call_tool(arguments)
    mcp_call(
      token: token.plaintext_token,
      method: 'tools/call',
      params: { name: 'cdr.report', arguments: arguments }
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
        'filters' => [{ 'field' => 'customer_acc_id', 'op' => 'like', 'value' => 1 }],
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
          'data' => [{ 'customer_acc_id' => 5, 'calls' => 100, 'distinct_src_numbers' => 1 }]
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
        'dimensions' => ['customer_acc_id'],
        'filters' => [{ 'field' => 'dst_country_id', 'op' => 'in', 'value' => [1, 7] }],
        'from' => from, 'to' => to
      )
      expect(result['isError']).to be_falsey
      payload = JSON.parse(error_text)
      expect(payload['rows']).to eq(1)
      expect(payload['data'].first).to include('customer_acc_id' => 5, 'distinct_src_numbers' => 1)
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
        'dimensions' => %w[customer_acc_id hour],
        'filters' => [{ 'field' => 'customer_acc_id', 'op' => 'eq', 'value' => 42 }],
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

    it 'surfaces a non-200 ClickHouse response as an error' do
      allow(ch_connection).to receive(:execute).and_return(double(status: 500, body: 'boom'))
      call_tool('measures' => ['calls'], 'from' => from, 'to' => to)
      expect(result['isError']).to be true
      expect(error_text).to match(/clickhouse error 500/i)
    end
  end
end
