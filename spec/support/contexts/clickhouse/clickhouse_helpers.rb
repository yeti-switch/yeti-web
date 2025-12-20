# frozen_string_literal: true

RSpec.shared_context :clickhouse_helpers do
  let!(:stub_clickhouse_query) do
    stub_request(:post, ClickHouse.config.url)
      .with(
        basic_auth: [ClickHouse.config.username, ClickHouse.config.password],
        query: {
          database: ClickHouse.config.database,
          **clickhouse_query_params,
          query: clickhouse_query_sql,
          send_progress_in_http_headers: 1
        }
      ).to_return(
      status: clickhouse_response_status,
      headers: { 'content-type' => 'application/json; charset=utf-8' },
      body: clickhouse_response_body.to_json
    )
  end
  let(:clickhouse_query_sql) { raise 'override let(:clickhouse_query_sql)' }
  let(:clickhouse_query_params) { {} }
  let(:clickhouse_response_status) { 200 }
  let(:clickhouse_response_body) do
    {
      data: clickhouse_data,
      rows: 123,
      meta: [baz: 'boo'],
      statistics: { foo: 'bar' }
    }
  end
  let(:clickhouse_data) { [] }
end
