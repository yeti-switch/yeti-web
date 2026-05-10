# frozen_string_literal: true

require_relative './base_processor'

class IpAccessProcessor < BaseProcessor
  self.logger = Rails.logger
  self.type = 'yeti_ip_access'

  def collect(metric)
    Thread.new do
      PrometheusExporter::Client.default.send_json(format_metric(metric))
    rescue StandardError => e
      logger.error { "IpAccessProcessor: #{e.class} #{e.message}\n#{e.backtrace&.join("\n")}" }
      CaptureError.capture(e, tags: { component: 'Prometheus', processor: 'IpAccessProcessor' })
    end
  end

  def self.collect_clickhouse_error_metric
    collect(clickhouse_errors: 1)
  end
end
