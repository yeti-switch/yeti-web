class AsyncBatchDestroyJob < ActiveJob::Base
  queue_as :records_change

  def perform(model_class, sql_query)
    model_class.constantize.find_by_sql(sql_query).each { |record| record.destroy! }
  end
end
