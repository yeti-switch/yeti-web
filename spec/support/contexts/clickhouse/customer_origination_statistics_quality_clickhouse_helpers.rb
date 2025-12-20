# frozen_string_literal: true

RSpec.shared_context :customer_origination_statistics_quality_clickhouse_helpers do
  include_context :clickhouse_helpers

  let(:clickhouse_query_sql) do
    <<-SQL.squish
      SELECT
        toUnixTimestamp(toStartOfMinute(time_start)) as t,
        toUInt32(count(*)) AS total_calls,
        toNullable(round(avgIf(duration, duration>0)/60,2)) AS acd,
        toNullable(round(countIf(duration>0)/count(*),3)*100) AS asr,
        toNullable(toFloat32(count(*)/60)) AS cps
      FROM cdrs
      WHERE #{clickhouse_query_sql_where_conditions.join(' AND ')}
      AND is_last_cdr = true
      GROUP BY t
      WITH TOTALS
      ORDER BY t
      WITH FILL
        FROM toUnixTimestamp(toStartOfMinute({from_time: DateTime})) TO toUnixTimestamp(now()) STEP 60
        INTERPOLATE(acd as Null, asr as Null, cps as 0)
      FORMAT JSONColumnsWithMetadata
    SQL
  end

  let(:clickhouse_query_sql_where_conditions) do
    [
      'customer_acc_id = {account_id: UInt32}',
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
        { name: 'acd', type: 'Nullable(Float64)' },
        { name: 'asr', type: 'Nullable(Float64)' },
        { name: 'cps', type: 'Nullable(Float32)' }
      ],
      statistics: {
        elapsed: 0.001234,
        rows_read: 1000,
        bytes_read: 50_000
      },
      totals: {
        t: 0,
        total_calls: 520,
        acd: '4.83',
        asr: '85.58',
        cps: '8.67'
      }
    }
  end

  let(:clickhouse_data) do
    {
      t: [1_734_700_000, 1_734_700_060, 1_734_700_120],
      total_calls: [180, 140, 200],
      acd: ['4.84', '4.84', '4.82'],
      asr: ['86.11', '85.71', '85.0'],
      cps: ['3.0', '2.33', '3.33']
    }
  end
end
