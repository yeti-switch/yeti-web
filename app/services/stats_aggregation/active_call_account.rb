# frozen_string_literal: true

module StatsAggregation
  class ActiveCallAccount < Base
    private

    def stats_class
      Stats::ActiveCallAccount
    end

    def agg_class
      Stats::AggActiveCallAccount
    end

    def aggregate_sql
      <<-SQL
        INSERT INTO #{agg_class.table_name}
        (max_originated_count, min_originated_count, avg_originated_count, max_terminated_count,
        min_terminated_count, avg_terminated_count, account_id, calls_time, created_at)
        SELECT
          max(originated_count) AS max_originated_count,
          min(originated_count) AS min_originated_count,
          avg(originated_count) AS avg_originated_count,
          max(terminated_count) AS max_terminated_count,
          min(terminated_count) AS min_terminated_count,
          avg(terminated_count) AS avg_terminated_count,
          account_id,
          date_trunc('hour', created_at) AS calls_time,
          NOW() AS created_at
        FROM #{stats_class.table_name}
        WHERE
          created_at < ?
        GROUP BY
          account_id,
          date_trunc('hour', created_at)
      SQL
    end
  end
end
