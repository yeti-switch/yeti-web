# frozen_string_literal: true

require 'semantic_logger'
require 'semantic_logger/appender/http'

# VictoriaLogs appender that never raises out of its constructor, #log or #batch.
#
# SemanticLogger::Appender::Http connects while it is built - #reopen ends with
# Net::HTTP#start - and config/initializers/semantic_logger.rb builds the appender in an
# after_initialize that rescues nothing, so an unreachable VictoriaLogs would fail the
# boot of every Rails process. The connection is established on the first write instead,
# and retried on every following one.
#
# SemanticLogger::QueueProcessor pops the whole queue at once, writes the log records
# first and only then replies to the :flush/:close commands it popped along with them.
# An exception from the write skips those replies, and they are already lost from the
# queue, so the SemanticLogger.flush of the `at_exit` hook waits for a reply that can
# never come - a process with an unreachable VictoriaLogs hangs on exit forever. Losing
# log records of an unavailable storage is acceptable, hanging the process that produced
# them is not.
class YetiVictoriaLogsAppender < SemanticLogger::Appender::Http
  # Errors of a connection that the peer closed while it was being reused.
  STALE_CONNECTION_ERRORS = [IOError, Errno::ECONNRESET, Errno::EPIPE, Errno::ECONNABORTED].freeze

  def reopen
    super
  rescue StandardError => e
    # Net::HTTP.new already assigned @http, only #start failed. Left unstarted for
    # #process_request to retry.
    report_failure(e, 0, 'connection failed')
  end

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

  # Net::HTTP reconnects a connection it knows to be closed, but not one that the peer
  # closes while the request is in flight - an idle timeout of a proxy, a kubectl
  # port-forward - and that surfaces as EOFError while the status line is read. It does
  # not retry the request itself either: Net::HTTP#max_retries applies to the idempotent
  # methods only, and a POST is not one of them. Retried once here, on a new connection.
  #
  # A batch that the server did receive before it hung up is delivered twice, which for
  # log records is better than losing it.
  def process_request(request, body = nil)
    retried = false
    begin
      @http.start unless @http.started?
      super
    rescue *STALE_CONNECTION_ERRORS
      raise if retried

      retried = true
      reopen
      retry
    end
  end

  # @return [TrueClass] the records are dropped, but the appender keeps working.
  def report_failure(exception, count, what = 'log record(s) discarded')
    # SemanticLogger::Processor.logger, $stderr by default. Never the appender itself.
    logger.error("VictoriaLogs: #{count} #{what}", exception)
    true
  rescue StandardError
    true
  end
end
