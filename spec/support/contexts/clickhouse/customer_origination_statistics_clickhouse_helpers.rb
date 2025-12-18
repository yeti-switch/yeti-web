# frozen_string_literal: true

RSpec.shared_context :customer_origination_statistics_clickhouse_helpers do
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
        round(sum(customer_price),2) as total_price
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
      'customer_acc_id = {account_id: UInt32}',
      'time_start >= {from_time: DateTime}',
      'is_last_cdr = true'
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
        total_calls: 520,
        successful_calls: 445,
        failed_calls: 75,
        total_duration: '2150.75',
        acd: '4.83',
        asr: '85.58',
        total_price: '186.5'
      }
    }
  end

  let(:clickhouse_data) do
    {
      t: [1_734_700_000, 1_734_700_060, 1_734_700_120],
      total_calls: [180, 140, 200],
      successful_calls: [155, 120, 170],
      failed_calls: [25, 20, 30],
      total_duration: ['750.25', '580.5', '820.0'],
      acd: ['4.84', '4.84', '4.82'],
      asr: ['86.11', '85.71', '85.0'],
      total_price: ['65.75', '50.25', '70.5']
    }
  end
end
