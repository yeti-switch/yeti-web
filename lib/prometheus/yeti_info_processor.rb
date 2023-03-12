# frozen_string_literal: true

require_relative './base_processor'

class YetiInfoProcessor < BaseProcessor
  self.logger = Rails.logger
  self.type = 'yeti_info'

  class << self
    def start(client: nil, frequency: 30, labels: nil)
      stop if running?

      client ||= PrometheusExporter::Client.default
      metric_labels = labels&.dup || {}
      process_collector = new(metric_labels)

      @thread = Thread.new do
        wrap_thread_loop(name) do
          ApplicationRecord.connection_pool.release_connection
          Cdr::Base.connection_pool.release_connection
          logger&.info { "Start #{name}" }
          loop do
            begin
              metrics = process_collector.collect
              metrics.each do |metric|
                client.send_json metric
              end
            rescue StandardError => e
              warn "#{self.class} Failed To Collect Stats #{e.class} #{e.message}"
              logger&.error { "#{e.class} #{e.message} #{e.backtrace&.join("\n")}" }
              CaptureError.capture(
                e,
                tags: { component: 'Prometheus', processor: 'YetiCronJobProcessor' },
                extra: { metrics: metrics }
              )
            end
            sleep frequency
          end
        end
      end

      true
    end

    def stop
      @thread&.kill
      @thread = nil
    end

    def running?
      defined?(@thread) && @thread
    end

    def wrap_thread_loop(*tags)
      return yield if logger.nil? || !logger.respond_to?(:tagged)

      logger.tagged(*tags) { yield }
    end
  end

  def collect
    version = Rails.application.config.app_build_info.fetch('version', 'unknown')

    [
      format_metric(
        online: 1,
        labels: { version: version }
      )
    ]
  end
end
