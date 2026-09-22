# frozen_string_literal: true

module CdrProcessor
  module Processors
    # Sends one HTTP request per CDR. The request body is a single CDR
    # represented as a JSON object. When `cdr_fields` is 'all' (or nil) every
    # CDR column is included; when it is an array only the listed fields are
    # kept (see CdrHttpBase#permit_field_for).
    #
    # Example request:
    #
    #   POST https://external-endpoint/api/cdr
    #   Content-Type: application/json
    #   X-Request-Id: 1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed
    #   X-Yeti-Cdr-Batch-Id: 42
    #   X-Yeti-Cdr-Event-Id: 1024
    #
    #   {
    #     "id": 12345,
    #     "uuid": "8f14e45f-ceea-467d-9e08-7c1b6c2f1a3e",
    #     "time_start": "2026-06-04T10:15:30.000Z",
    #     "time_connect": "2026-06-04T10:15:32.000Z",
    #     "time_end": "2026-06-04T10:16:10.000Z",
    #     "duration": 38,
    #     "success": true,
    #     "customer_id": 10,
    #     "customer_acc_id": 25,
    #     "vendor_id": 7,
    #     "vendor_acc_id": 13,
    #     "src_prefix_in": "12065550100",
    #     "src_prefix_out": "12065550100",
    #     "dst_prefix_in": "493054321000",
    #     "dst_prefix_out": "493054321000",
    #     "customer_price": "0.0190",
    #     "vendor_price": "0.0120",
    #     "profit": "0.0070",
    #     "internal_disconnect_code": 200,
    #     "internal_disconnect_reason": "Ok"
    #   }
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
