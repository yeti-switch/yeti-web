# frozen_string_literal: true

module CdrProcessor
  module Processors
    class CdrBilling < CdrProcessor::ConsumerGroup
      def perform_events(events)
        group = []
        events.each do |event|
          group << event.data
        end
        perform_group_with_timing(group)
      end

      # {'type' => [events]}
      def perform_group(group)
        sql = CdrProcessor::PrimaryDb.sanitize_sql_array(['SELECT * FROM billing.bill_cdr_batch(?, ?)', @batch_id, coder.dump(group)])
        primary_connection.execute(sql)
      end
    end
  end
end
