# frozen_string_literal: true

require 'semantic_logger'

# Plain one line stdout format of the processes that do not boot Rails:
#
#   2026-08-20T15:35:34.103216 INFO Worker for CdrProcessor::Processors::CdrBilling started
#
# The `:default` format of the Rails processes is not used here - and this is not only
# the format bin/cdr_processor had before it switched to SemanticLogger. These processes
# have no named tags and no request/SQL durations to show, so all `:default` would add is
# the pid, the thread and the logger name, that the systemd unit of the process already
# carries into journald. The record shipped to elasticsearch keeps every field regardless,
# it is formatted by YetiLogFormatter. See YetiLogSetup.add_stdout_appender.
class YetiPlainLogFormatter < SemanticLogger::Formatters::Base
  TIME_FORMAT = '%Y-%m-%dT%H:%M:%S.%6N'

  # @return [String]
  def call(log, _logger)
    result = +"#{log.time.strftime(TIME_FORMAT)} #{log.level.to_s.upcase} #{log.cleansed_message}"
    result << " #{log.payload.inspect}" if log.payload?
    append_exception(result, log) if log.exception
    result
  end

  private

  def append_exception(result, log)
    log.each_exception do |exception, index|
      result << "\n#{index.zero? ? '' : 'Caused by '}#{exception.class}: #{exception.message}"
      result << "\n#{exception.backtrace.join("\n")}" if exception.backtrace
    end
  end
end
