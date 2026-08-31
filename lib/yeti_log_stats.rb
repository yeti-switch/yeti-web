# frozen_string_literal: true

require 'semantic_logger'
require_relative 'yeti_log_component'

# Turns SemanticLogger.stats into the metric payloads of prometheus_exporter, see
# SemanticLoggerCollector for the series they end up as.
#
# Every queue is private to one process, so the payloads carry `component` - the field
# YetiLogFormatter writes into every log record, so that a series and its logs share a
# label - and a `pid`, without which the puma workers of a host overwrite each other.
#
# Depends on semantic_logger only, so that bin/cdr_processor reports the same metrics.
module YetiLogStats
  TYPE = 'yeti_log'

  # The queue of SemanticLogger itself, that every record passes through.
  PROCESSOR_QUEUE = 'processor'

  # The sentinel of `logging.elasticsearch.max_queue_size`, and not nil: Gauge#observe
  # deletes the series for nil, hiding an unbounded queue behind a silent process.
  UNBOUNDED = -1

  module_function

  # @param labels [Hash] extra labels of every payload, `processor` for example.
  # @return [Array<Hash>] one payload per queue.
  def metrics(labels = {})
    stats = SemanticLogger.stats
    common = { component: YetiLogComponent.current, pid: Process.pid }.merge(labels)

    payloads = [queue_metric(stats, common.merge(queue: PROCESSOR_QUEUE))]
    stats[:appenders].each do |appender|
      # An appender that writes inline has no queue of its own.
      next unless appender[:async]

      payloads << queue_metric(appender, common.merge(queue: appender[:name]))
    end
    payloads
  end

  # @param stats [Hash] SemanticLogger.stats, or one entry of its `appenders`.
  # @param labels [Hash]
  # @return [Hash]
  def queue_metric(stats, labels)
    {
      type: TYPE,
      metric_labels: labels,
      queue_size: stats[:queue_size],
      max_queue_size: stats[:capped] ? stats[:max_queue_size] : UNBOUNDED,
      thread_active: stats[:thread_active] ? 1 : 0,
      processed: stats[:processed],
      dropped: stats[:dropped]
    }
  end
end
