# frozen_string_literal: true

require 'pgq_prometheus'
require 'pgq_prometheus/processor'

PgqPrometheus.configure do |config|
  config.type = 'yeti_pgq_cdr'
end

# The processor tags every record its thread logs with its own class name, positionally:
# `tags: ["PgqPrometheus::Processor"]`. Tagged by name instead, so that YetiLogFormatter
# merges it into the root of the log record, the way YetiInfoProcessor does.
module PgqPrometheus::NamedLogTags
  # @param name [String] name of the collector.
  def wrap_thread_loop(name, &block)
    return yield if logger.nil? || !logger.respond_to?(:tagged)

    logger.tagged(processor: name, &block)
  end
end

PgqPrometheus::Processor.singleton_class.prepend PgqPrometheus::NamedLogTags
