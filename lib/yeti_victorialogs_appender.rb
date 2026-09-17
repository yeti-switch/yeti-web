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

  # Errors of a VictoriaLogs that cannot be reached at all, rather than one that answered
  # with something. Retried by #batch until RETRY_BUDGET_SECONDS is spent.
  UNAVAILABLE_ERRORS = [SystemCallError, IOError, SocketError, Net::OpenTimeout, Net::ReadTimeout].freeze

  # Wall clock a batch may spend being retried, and with it the delay that
  # SemanticLogger.flush of the `at_exit` hook can add to the shutdown of the process -
  # #batch holds the thread of the QueueProcessor, that replies to the :flush/:close
  # commands, so the budget has to stay well inside terminationGracePeriodSeconds.
  # One attempt may still be in flight when the budget is spent, so the worst case is
  # the budget plus the read timeout of a single request.
  RETRY_BUDGET_SECONDS = 10.0
  RETRY_INITIAL_DELAY = 0.1
  RETRY_MAX_DELAY = 2.0

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

  # Retries the batch instead of discarding it, and holds the thread of the
  # QueueProcessor while it does: nothing is popped from the queue meanwhile, so the
  # records of an unreachable VictoriaLogs pile up in the queue rather than being read
  # out of it and thrown away. The queue is bounded and reports what it drops
  # (max_queue_size, yeti_log_dropped_total), the write side is neither.
  #
  # Only an unreachable VictoriaLogs is retried. A request that was answered with an
  # error is not: the connection works, so the batch itself is what was rejected, and
  # retrying it would block every record behind it for the whole budget.
  def batch(logs)
    deadline = monotonic_now + RETRY_BUDGET_SECONDS
    attempt = 0

    begin
      attempt += 1
      super
    rescue *UNAVAILABLE_ERRORS => e
      delay = retry_delay(attempt)
      if monotonic_now + delay < deadline
        sleep delay
        retry
      end
      report_failure(e, logs.size)
    rescue StandardError => e
      report_failure(e, logs.size)
    end
  end

  private

  def monotonic_now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  # Doubles up to RETRY_MAX_DELAY, so that a VictoriaLogs that is down for the whole
  # budget is contacted a handful of times rather than hundreds.
  def retry_delay(attempt)
    [RETRY_INITIAL_DELAY * (2**(attempt - 1)), RETRY_MAX_DELAY].min
  end

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
