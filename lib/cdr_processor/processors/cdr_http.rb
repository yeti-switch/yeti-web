# frozen_string_literal: true

module CdrProcessor
  module Processors
    class CdrHttp < CdrProcessor::Processors::CdrHttpBase
      def perform_events(events)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        events.each do |event|
          next unless send_event?(event.data)

          @current_event_id = event.id
          perform_http_request permit_field_for(event.data)
        end
      ensure
        @current_event_id = nil
        @last_perform_group_duration_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000
      end

      private

      def http_method
        @params['method'].downcase.to_sym
      end

      def http_headers
        super.merge(
          'X-Yeti-Cdr-Batch-Id' => @batch_id.to_s,
          'X-Yeti-Cdr-Event-Id' => @current_event_id.to_s
        )
      end
    end
  end
end
