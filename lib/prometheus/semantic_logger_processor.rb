# frozen_string_literal: true

require_relative '../yeti_log_tags'
require_relative '../yeti_log_stats'

# Reports the queue state of the logging pipeline of its own process, see YetiLogStats
# for the payloads and SemanticLoggerCollector for the series they become.
#
# A processor of its own rather than a part of YetiInfoProcessor, although both report
# from every process at the same interval: YetiInfoProcessor is started in the
# `before_fork` hook of puma, so its thread belongs to the master and does not survive the
# fork, while every queue that can actually back up belongs to a worker - each of them
# gets a SemanticLogger thread of its own from the SemanticLogger.reopen of
# `before_worker_boot`. So this one is started per worker, next to the process
# instrumentation of prometheus_exporter, that is started there for the same reason.
class SemanticLoggerProcessor
  # Seconds between two reports, the max_metric_age of SemanticLoggerCollector is twice it.
  FREQUENCY = 30

  class << self
    attr_writer :logger

    def logger
      @logger ||= Rails.logger
    end

    # @param labels [Hash] extra labels of every payload, see YetiLogStats.
    # @return [TrueClass]
    def start(client: nil, frequency: FREQUENCY, labels: {})
      stop if running?

      client ||= PrometheusExporter::Client.default
      @thread = Thread.new do
        # Tagged by name and not positionally: YetiLogFormatter merges named tags into
        # the root of the log record.
        YetiLogTags.tagged(logger, { processor: name }) do
          logger&.info { "Start #{name}" }
          loop do
            report(client, labels)
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

    private

    def report(client, labels)
      YetiLogStats.metrics(labels).each do |metric|
        client.send_json(metric)
      rescue StandardError => e
        # Per payload: one queue failing to report must not stop the next one.
        report_failure(e)
      end
    rescue StandardError => e
      # And a failure to read the stats at all must not take the process down either.
      report_failure(e)
    end

    def report_failure(error)
      # Through the internal logger of SemanticLogger - stderr - and never through
      # Rails.logger: that one writes to the elasticsearch appender whose queue is being
      # reported, so a report of a full queue would be fed back into it.
      SemanticLogger::Processor.logger.error("#{name}: #{error.class} #{error.message}")
      CaptureError.capture(error, tags: { component: 'Prometheus', processor: name })
    rescue StandardError
      nil
    end
  end
end
