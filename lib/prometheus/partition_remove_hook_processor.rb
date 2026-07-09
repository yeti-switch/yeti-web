# frozen_string_literal: true

require_relative './base_processor'

class PartitionRemoveHookProcessor < BaseProcessor
  self.logger = Rails.logger
  self.type = 'yeti_partition_removing_hook'

  # Only bare counters are sent, labels are owned by PartitionRemoveHookCollector.
  def collect(metric)
    Thread.new do
      PrometheusExporter::Client.default.send_json({ type:, **metric })
    rescue StandardError => e
      logger.error { "PartitionRemoveHookProcessor: #{e.class} #{e.message}\n#{e.backtrace&.join("\n")}" }
      CaptureError.capture(e, tags: { component: 'Prometheus', processor: 'PartitionRemoveHookProcessor' })
    end
  end

  def self.collect_executions_metric
    collect(executions: 1)
  end

  def self.collect_success_metric
    collect(success: 1)
  end

  def self.collect_errors_metric
    collect(errors: 1)
  end

  def self.collect_duration_metric(duration)
    collect(duration:)
  end
end
