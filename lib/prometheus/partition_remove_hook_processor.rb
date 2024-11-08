# frozen_string_literal: true

require_relative './base_processor'

class PartitionRemoveHookProcessor < BaseProcessor
  self.logger = Rails.logger
  self.type = 'ruby_yeti_partition_removing_hook'

  def collect(metric)
    format_metric(metric)
  end

  def self.collect_executions_metric
    collect(executions: 1)
  end

  def self.collect_errors_metric
    collect(errors: 1)
  end

  def self.collect_duration_metric(duration)
    collect(duration:)
  end
end
