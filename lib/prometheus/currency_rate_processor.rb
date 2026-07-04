# frozen_string_literal: true

require_relative './base_processor'

class CurrencyRateProcessor < BaseProcessor
  self.logger = Rails.logger
  self.type = 'yeti_currency_rate'

  def collect(metric)
    Thread.new do
      PrometheusExporter::Client.default.send_json(format_metric(metric))
    rescue StandardError => e
      logger.error { "#{self.class.name}: #{e.class} #{e.message}\n#{e.backtrace&.join("\n")}" }
      CaptureError.capture(e, tags: { component: 'Prometheus', processor: self.class.name })
    end
  end

  def self.collect_updates_metric(count, provider_name)
    collect({ updates: count }, provider: provider_name)
  end

  def self.collect_error_metric(provider_name)
    collect({ errors: 1 }, provider: provider_name)
  end

  def self.collect_duration_metric(duration, provider_name)
    collect({ duration: duration }, provider: provider_name)
  end
end
