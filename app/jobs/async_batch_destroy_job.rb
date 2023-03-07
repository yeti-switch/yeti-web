# frozen_string_literal: true

class AsyncBatchDestroyJob < ApplicationJob
  include BatchJobsLog
  BATCH_SIZE = 1000
  queue_as 'batch_actions'

  attr_reader :model_class, :who_is

  def perform(model_class, sql_query, who_is)
    @model_class = model_class.constantize
    @who_is = who_is
    set_audit_log_data
    begin
      scoped_records = @model_class.find_by_sql(sql_query + " LIMIT #{BATCH_SIZE}")
      @model_class.transaction do
        scoped_records.each do |record|
          raise ActiveRecord::RecordNotDestroyed.new(error_message_for(record), record) unless record.destroy
        end
      end
    end until scoped_records.empty?
  end

  def error_message_for(record)
    "#{model_class} ##{record.id} can't be deleted: #{record.errors.full_messages.to_sentence}"
  end

  def reschedule_at(_time, _attempts)
    10.seconds.from_now
  end

  def max_attempts
    3
  end
end
