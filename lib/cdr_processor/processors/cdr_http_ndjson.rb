# frozen_string_literal: true

module CdrProcessor
  module Processors
    # Sends a single HTTP request per group of CDRs. The request body is
    # newline-delimited JSON: one CDR object per line, no envelope, no trailing
    # newline. The batch id is only available in the `batch_id_header` header.
    # Each CDR is filtered by `cdr_fields` the same way as in CdrHttp ('all'/nil
    # keeps every column, an array keeps only the listed fields).
    #
    # Example request:
    #
    #   POST https://external-endpoint/api/cdr
    #   Content-Type: application/x-ndjson
    #   X-Request-Id: 1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed
    #   X-Yeti-Cdr-Batch-Id: 42
    #
    #   {"id":12345,"uuid":"8f14e45f-ceea-467d-9e08-7c1b6c2f1a3e","time_start":"2026-06-04T10:15:30.000Z","duration":38,"success":true, ...}
    #   {"id":12346,"uuid":"c9f0f895-fb98-4b9c-9c5d-2f3b0c1a4d7e","time_start":"2026-06-04T10:17:05.000Z","duration":0,"success":false, ...}
    class CdrHttpNdjson < CdrProcessor::Processors::CdrHttpBase
      def perform_group(events)
        events_to_send = sendable_events(events)
        perform_http_request(events_to_send) if events_to_send.any?
      end

      private

      def default_content_type
        'application/x-ndjson'
      end

      def http_body(events)
        events.map(&:to_json).join("\n")
      end
    end
  end
end
