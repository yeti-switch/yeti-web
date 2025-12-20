# frozen_string_literal: true

RSpec.shared_context :customer_termination_statistics_clickhouse_helpers do
  include_context :clickhouse_helpers

  let(:clickhouse_query_sql) do
    <<-SQL.squish
      SELECT
        toUnixTimestamp(toStartOfMinute(time_start)) as t,
        toUInt32(count(*)) AS total_calls,
        toUInt32(countIf(duration>0)) as successful_calls,
        toUInt32(countIf(duration=0)) as failed_calls,
        round(sum(duration)/60,2) as total_duration,
        round(avgIf(duration, duration>0)/60,2) AS acd,
        round(countIf(duration>0)/count(*),3)*100 AS asr,
        round(sum(vendor_price),2) as total_price
      FROM cdrs
      WHERE #{clickhouse_query_sql_where_conditions.join(' AND ')}
      GROUP BY t
      WITH TOTALS
      ORDER BY t
      FORMAT JSONColumnsWithMetadata
    SQL
  end

  let(:clickhouse_query_sql_where_conditions) do
    [
      'vendor_acc_id = {account_id: UInt32}',
      'time_start >= {from_time: DateTime}'
    ]
  end

  let(:clickhouse_query_params) do
    {
      param_account_id: account.id,
      param_from_time: query[:'from-time']
    }
  end

  let(:clickhouse_response_body) do
    {
      data: clickhouse_data,
      rows: 3,
      meta: [
        { name: 't', type: 'UInt32' },
        { name: 'total_calls', type: 'UInt32' },
        { name: 'successful_calls', type: 'UInt32' },
        { name: 'failed_calls', type: 'UInt32' },
        { name: 'total_duration', type: 'Float64' },
        { name: 'acd', type: 'Float64' },
        { name: 'asr', type: 'Float64' },
        { name: 'total_price', type: 'Float64' }
      ],
      statistics: {
        elapsed: 0.001234,
        rows_read: 1000,
        bytes_read: 50_000
      },
      totals: {
        t: 0,
        total_calls: 450,
        successful_calls: 380,
        failed_calls: 70,
        total_duration: '1850.5',
        acd: '4.87',
        asr: '84.44',
        total_price: '125.75'
      }
    }
  end

  let(:clickhouse_data) do
    {
      t: [1_734_700_000, 1_734_700_060, 1_734_700_120],
      total_calls: [150, 120, 180],
      successful_calls: [130, 100, 150],
      failed_calls: [20, 20, 30],
      total_duration: ['650.5', '480.0', '720.0'],
      acd: ['5.0', '4.8', '4.8'],
      asr: ['86.67', '83.33', '83.33'],
      total_price: ['45.25', '32.5', '48.0']
    }
  end
end
