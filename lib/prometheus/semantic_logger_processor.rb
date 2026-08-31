# frozen_string_literal: true

require_relative '../yeti_log_tags'
require_relative '../yeti_log_stats'

# Reports the queue state of the logging pipeline of its own process, see YetiLogStats.
#
# Not a part of YetiInfoProcessor, although both report at the same interval: that one is
# started in the `before_fork` hook of puma, so its thread belongs to the master and does
# not survive the fork, while every queue that can back up belongs to a worker.
class SemanticLoggerProcessor
  # SemanticLoggerCollector expires a report at twice this.
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
        # Named and not positional: YetiLogFormatter merges named tags into the root.
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
      # Per payload: one queue failing to report must not stop the next one.
      YetiLogStats.metrics(labels).each do |metric|
        client.send_json(metric)
      rescue StandardError => e
        report_failure(e)
      end
    rescue StandardError => e
      report_failure(e)
    end

    def report_failure(error)
      # Never through Rails.logger: it writes to the elasticsearch appender whose queue is
      # being reported, so a report of a full queue would be fed back into it.
      SemanticLogger::Processor.logger.error("#{name}: #{error.class} #{error.message}")
      CaptureError.capture(error, tags: { component: 'Prometheus', processor: name })
    rescue StandardError
      nil
    end
  end
end
