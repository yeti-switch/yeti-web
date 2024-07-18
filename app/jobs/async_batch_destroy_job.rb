# frozen_string_literal: true

class AsyncBatchDestroyJob < ApplicationJob
  include BatchJobsLog
  BATCH_SIZE = 1000
  queue_as 'batch_actions'

  attr_reader :model_class, :who_is, :sql_query

  def perform(model_class, sql_query, who_is)
    @model_class = model_class.constantize
    @sql_query = sql_query
    @who_is = who_is
    set_audit_log_data
    @model_class.transaction do
      relation.find_in_batches(batch_size: BATCH_SIZE) do |records|
        records.each do |record|
          unless record.destroy
            logger.warn { error_message_for(record) }
            next
          end
        end
      end
    end
  end

  def relation
    if @sql_query.present? && extract_where_clause(@sql_query).present?
      @model_class.where(extract_where_clause(sql_query))
    else
      @model_class.all
    end
  end

  def error_message_for(record)
    "#{model_class} ##{record.id} can't be deleted: #{record.errors.full_messages.to_sentence}"
  end

  def extract_where_clause(sql_query)
    where_clause_match = sql_query.match(/WHERE\s+(.+)\z/i)
    where_clause_match ? where_clause_match[1].strip : nil
  end

  def reschedule_at(_time, _attempts)
    10.seconds.from_now
  end

  def max_attempts
    3
  end
end
