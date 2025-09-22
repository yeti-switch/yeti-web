# frozen_string_literal: true

require_relative './base_processor'

class CdrCompactionHookProcessor < BaseProcessor
  self.logger = Rails.logger
  self.type = 'yeti_cdr_compaction_hook'

  def collect(metric)
    Thread.new do
      PrometheusExporter::Client.default.send_json(format_metric(metric))
    rescue StandardError => e
      logger.error { "#{self.class.name}: #{e.class} #{e.message}\n#{e.backtrace&.join("\n")}" }
      CaptureError.capture(e, tags: { component: 'Prometheus', processor: self.class.name })
    end
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
