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

    @model_class.where(id: record_ids(sql_query)).find_in_batches(batch_size: BATCH_SIZE) do |records|
      records.each do |record|
        delete_record(record)
      end
    end
  end

  def record_ids(sql_query)
    @model_class.find_by_sql(sql_query).pluck(:id)
  end

  def delete_record(record)
    unless record.destroy
      Rails.logger.warn "#{@model_class} ##{record.id} can't be deleted: #{record.errors.full_messages.to_sentence}"
    end
  rescue ActiveRecord::InvalidForeignKey => e
    Rails.logger.error error_message_for(id: record.id, error_class: e.class)
  end

  def error_message_for(id:, error_class:)
    "#{@model_class} ##{id} can't be deleted: #{error_class}"
  end

  def reschedule_at(_time, _attempts)
    10.seconds.from_now
  end

  def max_attempts
    3
  end
end
