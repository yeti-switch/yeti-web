# frozen_string_literal: true

class AsyncBatchUpdateJob < ApplicationJob
  include BatchJobsLog
  BATCH_SIZE = 1000
  queue_as 'batch_actions'

  attr_reader :model_class, :sql_query, :who_is

  def perform(model_class, sql_query, changes, who_is)
    @model_class = model_class.constantize
    @sql_query = sql_query
    @who_is = who_is
    set_audit_log_data
    @model_class.connection.cache do
      @model_class.transaction do
        ids = @model_class.connection.select_values(ids_sql)
        ids.each_slice(BATCH_SIZE) do |batch_ids|
          scoped_records = @model_class.find(batch_ids)
          scoped_records.each { |record| record.update!(changes) }
        end
      end
    end
  end

  def count_sql_query
    sql_query.gsub(/^SELECT .* FROM/, 'SELECT COUNT(*) FROM')
             .gsub(/ORDER BY .* (ASC)|(DESC)/, '')
  end

  # Fetch all IDs at once, because earlier records updates can lead to change sql_query result.
  def ids_sql
    id_path = sql_query[/FROM\s(.*?)(\s|\z)/m, 1] + '."id"'

    sql_query.gsub(/ORDER BY .* (ASC)|(DESC)/, '')
             .gsub(/^SELECT .* FROM/, "SELECT #{id_path} FROM")
  end

  def reschedule_at(_time, _attempts)
    10.seconds.from_now
  end

  def max_attempts
    3
  end
end
