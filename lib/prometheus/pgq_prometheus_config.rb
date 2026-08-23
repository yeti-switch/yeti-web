# frozen_string_literal: true

require 'pgq_prometheus'
require 'pgq_prometheus/processor'
require_relative '../yeti_log_tags'

PgqPrometheus.configure do |config|
  config.type = 'yeti_pgq_cdr'
end

# The processor tags every record its thread logs with its own class name, positionally:
# `tags: ["PgqPrometheus::Processor"]`. Tagged by name instead, so that YetiLogFormatter
# merges it into the root of the log record, the way YetiInfoProcessor does.
module PgqPrometheus::NamedLogTags
  # The splat of the gem is kept and anything but its single tag is delegated: this runs
  # as the whole body of the Thread of Processor.start, that nothing joins, so a version
  # of the gem passing another tag would kill the collector thread unnoticed.
  #
  # @param tags [Array<String>] name of the collector.
  def wrap_thread_loop(*tags, &block)
    return super unless tags.size == 1

    YetiLogTags.tagged(logger, { processor: tags.first }, &block)
  end
end

PgqPrometheus::Processor.singleton_class.prepend PgqPrometheus::NamedLogTags
