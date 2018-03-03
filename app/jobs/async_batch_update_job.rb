class AsyncBatchUpdateJob
  include BatchJobsLog
  BATCH_SIZE = 1000

  attr_reader :model_class, :sql_query, :changes, :who_is

  def initialize(model_class, sql_query, changes, who_is)
    @model_class = model_class
    @sql_query = sql_query
    @changes = changes
    @who_is = who_is
  end

  def perform
    set_audit_log_data
    model_class.constantize.transaction do
      total_count = model_class.constantize.count_by_sql count_sql_query

      (total_count.to_f / BATCH_SIZE).ceil.times do |batch_number|
        offset = batch_number * BATCH_SIZE
        scoped_records = model_class.constantize.find_by_sql(order_by_id_sql + " OFFSET #{offset} LIMIT #{BATCH_SIZE}")
        scoped_records.each { |record| record.update!(changes) }
      end
    end
  end

  def count_sql_query
    sql_query.gsub(/^SELECT .* FROM/, 'SELECT COUNT(*) FROM')
             .gsub(/ORDER BY .* (ASC)|(DESC)/, '')
  end

  # Some records are sorted by updated_at column by default, and that breaks our OFFSET setting, because freshly
  # updated records go up in query queue. To avoid that we change default ordering to order by id.
  def order_by_id_sql
    order_by_id_path = sql_query[/FROM\s(.*?)(\s|\z)/m, 1] + '."id"'
    result_sql = sql_query.gsub(/ORDER BY .* (ASC)|(DESC)/, "ORDER BY #{order_by_id_path} ASC")
    result_sql += " ORDER BY #{order_by_id_path} ASC" unless sql_query.include? 'ORDER'
    result_sql
  end

  def reschedule_at(time, attempts)
    10.seconds.from_now
  end

  def max_attempts
    3
  end

end
