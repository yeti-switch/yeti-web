class AsyncBatchUpdateJob < ActiveJob::Base
  queue_as :records_change

  def perform(model_class, sql_query, changes)
    limit = 1000
    total_count = model_class.constantize.count_by_sql(total_count_sql sql_query)
    sql_query_reordered = order_by_id_sql sql_query

    ((total_count.to_f / limit).ceil).times do |batch_number|
      offset = batch_number * limit
      scoped_records = model_class.constantize.find_by_sql(sql_query_reordered + " OFFSET #{offset} LIMIT #{limit}")
      scoped_records.each { |record| record.update!(changes) }
    end

  end

  def total_count_sql(sql_query)
    sql_query.gsub(/^SELECT .* FROM/, 'SELECT COUNT(*) FROM')
             .gsub(/ORDER BY .* (ASC)|(DESC)/, '')
  end

  # Some records are sorted by updated_at column by default, and that breaks our OFFSET setting, because freshly
  # updated records go up in query queue. To avoid that we change default ordering to order by id.
  def order_by_id_sql(sql_query)
    order_by_id_path = sql_query[/FROM\s(.*?)(\s|\z)/m, 1] + '."id"'
    result_sql = sql_query.gsub(/ORDER BY .* (ASC)|(DESC)/, "ORDER BY #{order_by_id_path} ASC")
    result_sql += " ORDER BY #{order_by_id_path} ASC" unless sql_query.include? 'ORDER'
    result_sql
  end

end
