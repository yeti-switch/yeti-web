# frozen_string_literal: true

module StatsAggregation
  class Base < ApplicationService
    def call
      stats_class.transaction do
        aggregate_stats
        delete_stat_records
      end
    end

    private

    def day_ago
      @day_ago ||= 24.hours.ago
    end

    def stats_class
      raise NotImplementedError
    end

    def agg_class
      raise NotImplementedError
    end

    def entity_key
      raise NotImplementedError
    end

    def aggregate_stats
      SqlCaller::Cdr.execute(aggregate_sql, day_ago)
    end

    def aggregate_sql
      <<-SQL
        INSERT INTO #{agg_class.table_name}
        (#{entity_key}, max_count, min_count, calls_time, avg_count, created_at)
        SELECT
          #{entity_key},
          max(count) AS max_count,
          min(count) AS min_count,
          date_trunc('hour', created_at) AS calls_time,
          avg(count) AS avg_count,
          NOW() AS created_at
        FROM #{stats_class.table_name}
        WHERE
          created_at < ?
        GROUP BY
          #{entity_key},
          date_trunc('hour', created_at)
      SQL
    end

    def delete_stat_records
      stats_class.where('created_at < ?', day_ago).delete_all
    end
  end
end
