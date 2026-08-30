# frozen_string_literal: true

require 'semantic_logger'
require_relative 'yeti_log_component'

# Turns SemanticLogger.stats into the metric payloads of prometheus_exporter, see
# SemanticLoggerCollector for the series they end up as.
#
# Every queue reported here is private to one process: SemanticLogger hands each log
# record to a single processing thread, that hands it to the thread of every appender
# that writes asynchronously. So a backlog is a property of the process that has it, and
# the payloads name that process the way its own log records do - `component`, the field
# YetiLogFormatter writes into every record, so that a series and the logs behind it are
# selected by the same label - plus a `pid`, because puma runs several workers per host
# and they would otherwise overwrite each other's series.
#
# Depends on semantic_logger only, so that bin/cdr_processor, that does not boot Rails,
# reports the same metrics as the rest.
module YetiLogStats
  TYPE = 'yeti_log'

  # The queue of SemanticLogger itself, that every log record passes through, as opposed
  # to the queue of one asynchronous appender.
  PROCESSOR_QUEUE = 'processor'

  # `max_queue_size` of a queue that holds as much as it is given. The sentinel of the
  # `logging.elasticsearch.max_queue_size` config, and not 0 or a missing series, so that
  # an unbounded queue is still visible as one.
  UNBOUNDED = -1

  module_function

  # @param labels [Hash] extra labels of every payload, `processor` for example.
  # @return [Array<Hash>] one payload per queue.
  def metrics(labels = {})
    stats = SemanticLogger.stats
    common = { component: YetiLogComponent.current, pid: Process.pid }.merge(labels)

    payloads = [queue_metric(stats, common.merge(queue: PROCESSOR_QUEUE))]
    stats[:appenders].each do |appender|
      # An appender that writes inline has no queue and no counters of its own.
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
