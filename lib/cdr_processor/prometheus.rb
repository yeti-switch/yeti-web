# frozen_string_literal: true

require 'prometheus_exporter'
require 'prometheus_exporter/client'
require_relative '../yeti_log_stats'

module CdrProcessor
  class Prometheus
    # Matches the interval SemanticLoggerProcessor reports at in the Rails processes.
    LOG_STATS_INTERVAL = 30

    attr_reader :client

    def initialize(host:, port:, default_labels: {})
      @client = PrometheusExporter::Client.new(
        host: host,
        port: port,
        custom_labels: default_labels
      )
    end

    # Reports the queue state of the logging pipeline, see YetiLogStats. A thread of its
    # own and not a part of the batch loop: a backlog matters most when the processor is
    # stuck and writes no batches at all.
    #
    # @param processor_name [String]
    # @return [Thread]
    def start_log_stats(processor_name:, interval: LOG_STATS_INTERVAL)
      Thread.new do
        loop do
          report(processor_name)
          sleep interval
        end
      end
    end

    # @param processor_name [String]
    # @param duration_ms [Numeric] total batch processing duration in milliseconds
    # @param perform_group_duration_ms [Numeric, nil] time spent sending data to target in milliseconds
    # @param events_count [Integer]
    def send_batch_metric(processor_name:, duration_ms:, perform_group_duration_ms:, events_count:)
      metric = {
        type: 'yeti_cdr_processor',
        metric_labels: { processor: processor_name },
        batches: 1,
        events: events_count,
        duration: duration_ms
      }
      metric[:perform_group_duration] = perform_group_duration_ms if perform_group_duration_ms
      @client.send_json(metric)
    end

    private

    def report(processor_name)
      # Per payload: one queue failing to report must not stop the next one.
      YetiLogStats.metrics(processor: processor_name).each do |metric|
        @client.send_json(metric)
      rescue StandardError => e
        report_failure(e)
      end
    rescue StandardError => e
      report_failure(e)
    end

    # Never through a SemanticLogger::Logger: it writes to the elasticsearch appender
    # whose queue is being reported, so a report of a full queue would feed back into it.
    def report_failure(error)
      SemanticLogger::Processor.logger.warn("Failed to report the log queue state: #{error.class}: #{error.message}")
    rescue StandardError
      nil
    end
  end
end
