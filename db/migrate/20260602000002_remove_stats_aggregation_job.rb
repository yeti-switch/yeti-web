# frozen_string_literal: true

class RemoveStatsAggregationJob < ActiveRecord::Migration[7.2]
  # The hourly stats rollup was removed; raw active-call stats are kept for a
  # month and reduced client-side. Drop the now-unused cron job row.
  def up
    execute <<-SQL
      DELETE FROM sys.jobs WHERE name = 'StatsAggregation';
    SQL
  end

  def down
    execute <<-SQL
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (7, 'StatsAggregation', NULL, NULL, NULL);
    SQL
  end
end
