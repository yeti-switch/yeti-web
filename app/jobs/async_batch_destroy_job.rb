# frozen_string_literal: true

class AsyncBatchDestroyJob
  include BatchJobsLog
  BATCH_SIZE = 1000

  attr_reader :model_class, :sql_query, :who_is

  def initialize(model_class, sql_query, who_is)
    @model_class = model_class
    @sql_query = sql_query
    @who_is = who_is
  end

  def perform
    set_audit_log_data
    begin
      scoped_records = model_class.constantize.find_by_sql(sql_query + " LIMIT #{BATCH_SIZE}")
      model_class.constantize.transaction do
        scoped_records.each(&:destroy!)
      end
    end until scoped_records.empty?
  end

  def reschedule_at(_time, _attempts)
    10.seconds.from_now
  end

  def max_attempts
    3
  end
end
