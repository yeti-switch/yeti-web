# frozen_string_literal: true

require 'semantic_logger'
require 'semantic_logger/appender/elasticsearch'

# Elasticsearch appender that never raises out of #log and #batch.
#
# SemanticLogger::Appender::AsyncBatch pops the whole queue at once, writes the log
# records first and only then replies to the :flush/:close commands it popped along
# with them. An exception from the write skips those replies, and they are already
# lost from the queue, so the SemanticLogger.flush of the `at_exit` hook waits for a
# reply that can never come - a process with an unreachable elasticsearch hangs on
# exit forever. Losing log records of an unavailable storage is acceptable, hanging
# the process that produced them is not.
class YetiElasticsearchAppender < SemanticLogger::Appender::Elasticsearch
  def log(log)
    super
  rescue StandardError => e
    report_failure(e, 1)
  end

  def batch(logs)
    super
  rescue StandardError => e
    report_failure(e, logs.size)
  end

  private

  # @return [TrueClass] the record is dropped, but the appender keeps working.
  def report_failure(exception, count)
    # SemanticLogger::Processor.logger, $stderr by default. Never the appender itself.
    logger.error("Elasticsearch: #{count} log record(s) discarded", exception)
    true
  rescue StandardError
    true
  end
end
