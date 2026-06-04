# frozen_string_literal: true

module CdrProcessor
  module Processors
    # Sends a single HTTP request per group of CDRs. The request body is a JSON
    # object with the batch id and a `data` array holding the CDRs. Each CDR is
    # filtered by `cdr_fields` the same way as in CdrHttp ('all'/nil keeps every
    # column, an array keeps only the listed fields).
    #
    # Example request:
    #
    #   POST https://external-endpoint/api/cdr
    #   Content-Type: application/json
    #   X-Request-Id: 1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed
    #   X-Yeti-Cdr-Batch-Id: 42
    #
    #   {
    #     "batch_id": 42,
    #     "data": [
    #       {
    #         "id": 12345,
    #         "uuid": "8f14e45f-ceea-467d-9e08-7c1b6c2f1a3e",
    #         "time_start": "2026-06-04T10:15:30.000Z",
    #         "time_connect": "2026-06-04T10:15:32.000Z",
    #         "time_end": "2026-06-04T10:16:10.000Z",
    #         "duration": 38,
    #         "success": true,
    #         "customer_id": 10,
    #         "customer_acc_id": 25,
    #         "vendor_id": 7,
    #         "vendor_acc_id": 13,
    #         "src_prefix_in": "12065550100",
    #         "src_prefix_out": "12065550100",
    #         "dst_prefix_in": "493054321000",
    #         "dst_prefix_out": "493054321000",
    #         "customer_price": "0.0190",
    #         "vendor_price": "0.0120",
    #         "profit": "0.0070",
    #         "internal_disconnect_code": 200,
    #         "internal_disconnect_reason": "Ok"
    #       },
    #       {
    #         "id": 12346,
    #         "uuid": "c9f0f895-fb98-4b9c-9c5d-2f3b0c1a4d7e",
    #         "time_start": "2026-06-04T10:17:05.000Z",
    #         "time_connect": null,
    #         "time_end": "2026-06-04T10:17:11.000Z",
    #         "duration": 0,
    #         "success": false,
    #         "customer_id": 10,
    #         "customer_acc_id": 25,
    #         "vendor_id": 7,
    #         "vendor_acc_id": 13,
    #         "src_prefix_in": "12065550100",
    #         "src_prefix_out": "12065550100",
    #         "dst_prefix_in": "493054321999",
    #         "dst_prefix_out": "493054321999",
    #         "customer_price": "0.0000",
    #         "vendor_price": "0.0000",
    #         "profit": "0.0000",
    #         "internal_disconnect_code": 487,
    #         "internal_disconnect_reason": "Request Terminated"
    #       }
    #     ]
    #   }
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
