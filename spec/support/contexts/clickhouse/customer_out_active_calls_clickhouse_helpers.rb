# frozen_string_literal: true

RSpec.shared_context :customer_out_active_calls_clickhouse_helpers do
  include_context :clickhouse_helpers

  let(:clickhouse_query_sql) do
    <<-SQL.squish
        SELECT
          #{ClickhouseReport::CustomerOutgoingActiveCalls::COLUMNS.map(&:to_s).join(', ')}
        FROM active_calls
        WHERE #{clickhouse_query_sql_where_conditions.join(' AND ')}
        ORDER BY start_time DESC
        FORMAT JSON
    SQL
  end
  let(:clickhouse_query_sql_where_conditions) do
    [
      'snapshot_timestamp = (select max(snapshot_timestamp) from active_calls)',
      'customer_id = {customer_id: Int32}',
      'customer_acc_id = {account_id: Int32}'
    ]
  end

  let(:clickhouse_query_params) do
    {
      param_customer_id: customer.id,
      param_account_id: account.id
    }
  end
  let(:clickhouse_data) do
    [
      {
        snapshot_timestamp: '2025-12-18 15:38:34',
        start_time: '2025-12-18 15:38:34',
        connect_time: nil,
        destination_prefix: '123',
        destination_initial_interval: 1,
        destination_initial_rate: '2.3',
        destination_next_interval: 60,
        destination_next_rate: '3.4',
        destination_fee: '0.0',
        src_name_in: 'test',
        src_prefix_in: '456',
        dst_prefix_in: '678',
        src_prefix_routing: '333',
        dst_prefix_routing: '7863',
        from_domain: 'qwe',
        to_domain: 'asd',
        ruri_domain: 'qwe.asd',
        diversion_in: nil,
        pai_in: nil,
        ppi_in: nil,
        privacy_in: nil,
        rpid_in: nil,
        rpid_privacy_in: nil,
        auth_orig_transport_protocol_id: 123,
        auth_orig_ip: '10.20.30.40',
        auth_orig_port: 8888
      }
    ]
  end
end
