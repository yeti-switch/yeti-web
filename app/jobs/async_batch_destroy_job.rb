class AsyncBatchDestroyJob < ActiveJob::Base
  queue_as :records_change

  def perform(model_class, sql_query)
    offset = 0
    limit = 1000
    begin
      scoped_records = model_class.constantize.find_by_sql(sql_query + " OFFSET #{offset} LIMIT #{limit}")
      scoped_records.each { |record| record.destroy! }
    end until scoped_records.empty?
  end

end
