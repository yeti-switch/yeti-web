# frozen_string_literal: true

module CdrProcessor
  module Processors
    # Sends a single HTTP request per group of CDRs. The request body is
    # newline-delimited JSON: one CDR object per line, no envelope, no trailing
    # newline. The batch id is only available in the `batch_id_header` header
    # (default X-Yeti-Cdr-Batch-Id); Content-Type is `content_type` (default
    # application/x-ndjson). Each CDR is filtered by `cdr_fields` the same way
    # as in CdrHttp ('all'/nil keeps every column, an array keeps only the
    # listed fields).
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
      DEFAULT_BATCH_ID_HEADER = 'X-Yeti-Cdr-Batch-Id'
      DEFAULT_CONTENT_TYPE = 'application/x-ndjson'

      def initialize(...)
        super(...)
        @batch_id_header = @params['batch_id_header'].presence || DEFAULT_BATCH_ID_HEADER
        @content_type = @params['content_type'].presence || DEFAULT_CONTENT_TYPE
      end

      def perform_group(events)
        events_to_send = events.select { |event| send_event?(event) }
        return if events_to_send.empty?

        permitted_events = events_to_send.map { |event| permit_field_for(event) }
        perform_http_request(permitted_events)
      end

      private

      # Precedence: content_type < headers < X-Request-Id and batch_id_header.
      def http_headers
        { 'Content-Type' => @content_type }.merge(super).merge(@batch_id_header => @batch_id.to_s)
      end

      def http_body(events)
        events.map(&:to_json).join("\n")
      end
    end
  end
end
