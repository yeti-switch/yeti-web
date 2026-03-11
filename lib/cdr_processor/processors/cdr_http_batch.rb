# frozen_string_literal: true

module CdrProcessor
  module Processors
    class CdrHttpBatch < CdrProcessor::Processors::CdrHttpBase
      def perform_group(events)
        events_to_send = events.select { |event| send_event?(event) }
        return if events_to_send.empty?

        permitted_events = events_to_send.map { |event| permit_field_for(event) }
        perform_http_request(permitted_events)
      end

      private

      def http_headers
        super.merge('X-Yeti-Cdr-Batch-Id' => @batch_id.to_s)
      end

      def http_body(events)
        { batch_id: @batch_id, data: events }.to_json
      end
    end
  end
end
