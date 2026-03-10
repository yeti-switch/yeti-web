# frozen_string_literal: true

require 'prometheus_exporter'
require 'prometheus_exporter/client'

module CdrProcessor
  class Prometheus
    attr_reader :client

    def initialize(host:, port:, default_labels: {})
      @client = PrometheusExporter::Client.new(
        host: host,
        port: port,
        custom_labels: default_labels
      )
    end

    # @param processor_name [String]
    # @param duration_ms [Numeric] batch processing duration in milliseconds
    # @param events_count [Integer]
    def send_batch_metric(processor_name:, duration_ms:, events_count:)
      @client.send_json(
        type: 'yeti_cdr_processor',
        metric_labels: { processor: processor_name },
        batches: 1,
        events: events_count,
        duration: duration_ms
      )
    end
  end
end
