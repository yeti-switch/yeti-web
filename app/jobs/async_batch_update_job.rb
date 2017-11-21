class AsyncBatchUpdateJob < ActiveJob::Base
  queue_as :records_change

  def perform(model_class, sql_query, changes)
    model_class.constantize.find_by_sql(sql_query).each { |record| record.update!(changes) }
  end
end
