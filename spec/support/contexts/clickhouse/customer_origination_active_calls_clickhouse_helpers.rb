# frozen_string_literal: true

RSpec.shared_context :customer_origination_active_calls_clickhouse_helpers do
  include_context :clickhouse_helpers

  let(:clickhouse_query_sql) do
    <<-SQL.squish
      SELECT
        toUnixTimestamp(snapshot_timestamp) as t,
        toUInt32(count(*)) AS calls
      FROM active_calls
      WHERE
        customer_acc_id = {account_id: UInt32} AND
        snapshot_timestamp >= {from_time: DateTime}
      GROUP BY t
      ORDER BY t
      WITH FILL
        FROM toUnixTimestamp(toStartOfMinute({from_time: DateTime}))
        TO toUnixTimestamp(now())
        STEP 60
      FORMAT JSONColumnsWithMetadata
    SQL
  end

  let(:clickhouse_query_params) do
    {
      param_account_id: account.id,
      param_from_time: from_time
    }
  end

  let(:clickhouse_data) do
    {
      t: [1_734_700_000, 1_734_700_060, 1_734_700_120],
      calls: [12, 8, 15]
    }
  end
end
