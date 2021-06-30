# frozen_string_literal: true

require_relative './base_processor'

class YetiCronJobProcessor < BaseProcessor
  self.logger = Rails.logger
  self.type = 'yeti_cron_job'

  def initialize(labels = nil)
    super
    @metric_labels.merge!(pid: Process.pid)
  end

  # @param data [Hash]
  def collect(data)
    metric = format_metric(data)
    in_thread do
      PrometheusExporter::Client.default.send_json(metric)
    end
  end
end

private

def in_thread
  Thread.new do
    yield
  rescue StandardError => e
    logger.error { "YetiCronJobProcessor: #{e.class} #{e.message}\n#{e.backtrace&.join("\n")}" }
    CaptureError.capture(e, tags: { component: 'Prometheus', processor: 'YetiCronJobProcessor' })
  end
end
