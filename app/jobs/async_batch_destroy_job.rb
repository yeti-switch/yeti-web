class AsyncBatchDestroyJob
  include BatchJobsLog
  BATCH_SIZE = 1000

  attr_reader :model_class, :sql_query

  def initialize(model_class, sql_query)
    @model_class = model_class
    @sql_query = sql_query
  end

  def perform
    model_class.constantize.transaction do
      begin
        scoped_records = model_class.constantize.find_by_sql(sql_query + " LIMIT #{BATCH_SIZE}")
        scoped_records.each { |record| record.destroy! }
      end until scoped_records.empty?
    end
  end

  def reschedule_at(time, attempts)
    10.seconds.from_now
  end

  def max_attempts
    3
  end

  def success(job)
    LogicLog.create!(
      source: 'Batch destroy job ' + job.id.to_s,
      level: 0,
      msg: 'success'
    )
  end

  def failure(job)
    LogicLog.create!(
      source: 'Batch destroy job ' + job.id.to_s,
      level: 0,
      msg: job.last_error
    )
  end

end
