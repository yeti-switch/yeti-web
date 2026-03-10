# frozen_string_literal: true

module CdrProcessor
  module Processors
    class CdrStat < CdrProcessor::ConsumerGroup
      def initialize(logger, queue, consumer, options)
        super
        @sp_name = options['stored_procedure']
      end

      def perform_batch
        safe_batch_perform do
          start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          events_qty = cdr_connection.select_value("SELECT processed_records FROM #{@sp_name}()")
          @last_perform_group_duration_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000

          if events_qty.nil?
            # no batch
            return 0
          end

          events_qty = events_qty.to_i
          if events_qty.zero?
            log_info 'Empty batch'
            return -1
          end

          log_info "=> batch: events #{events_qty}"
          events_qty
        end
      end
    end
  end
end
