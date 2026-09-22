# frozen_string_literal: true

require 'semantic_logger'

# Plain one line stdout format of the processes that do not boot Rails:
#
#   2026-08-20T15:35:34.103216 INFO Worker for CdrProcessor::Processors::CdrBilling started
#   2026-08-20T15:35:35.201133 INFO HTTP request completed batch_id=42 request_id=1b9d... http_status=200 duration=12.3ms
#
# Named tags and the duration follow the message as key=value pairs, so that journald
# shows the same ids VictoriaLogs indexes (see YetiLogFormatter). Not the `:default`
# format of the Rails processes: all it would add is the pid, the thread and the logger
# name, that the systemd unit already carries into journald.
class YetiPlainLogFormatter < SemanticLogger::Formatters::Base
  TIME_FORMAT = '%Y-%m-%dT%H:%M:%S.%6N'

  # @return [String]
  def call(log, _logger)
    result = +"#{log.time.strftime(TIME_FORMAT)} #{log.level.to_s.upcase} #{log.cleansed_message}"
    result << " #{log.payload.inspect}" if log.payload?
    append_named_tags(result, log)
    result << " duration=#{log.duration.round(1)}ms" if log.duration
    append_exception(result, log) if log.exception
    result
  end

  private

  def append_named_tags(result, log)
    log.named_tags&.each { |key, value| result << " #{key}=#{value}" }
  end

  def append_exception(result, log)
    log.each_exception do |exception, index|
      result << "\n#{index.zero? ? '' : 'Caused by '}#{exception.class}: #{exception.message}"
      result << "\n#{exception.backtrace.join("\n")}" if exception.backtrace
    end
  end
end
