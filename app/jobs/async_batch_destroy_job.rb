class AsyncBatchDestroyJob < ActiveJob::Base
  queue_as :batch_actions

  BATCH_SIZE = 1000

  def perform(model_class, sql_query)
    begin
      scoped_records = model_class.constantize.find_by_sql(sql_query + " LIMIT #{BATCH_SIZE}")
      scoped_records.each { |record| record.destroy! }
    end until scoped_records.empty?
  end

end
