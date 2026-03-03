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
          events_qty = Cdr::Base.fetch_sp_val("SELECT processed_records FROM #{@sp_name}()")

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
