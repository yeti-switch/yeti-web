# frozen_string_literal: true

require 'digest'
require 'openssl'

module CdrProcessor
  module Processors
    # Sends CDRs to an external endpoint in bulks of at most `bulk_size` events,
    # so that one pgq batch becomes several bounded HTTP requests instead of a
    # single unbounded one. Each bulk is acknowledged (pgq_ext.set_event_done)
    # right after its request succeeds, so a crash mid-batch resumes at the
    # first unsent bulk rather than replaying the whole batch.
    #
    # `event_bulk_id` is derived from the batch id and the event ids of the
    # bulk, so a replayed bulk carries the same id and the receiver can
    # deduplicate it. When `hmac_secret` is set the body is signed with
    # HMAC-SHA256 and the signature is sent in the X-HMAC-Signature header.
    #
    # Each CDR is filtered by `cdr_fields` the same way as in CdrHttp
    # ('all'/nil keeps every column, an array keeps only the listed fields) and
    # by `data_filters`; filtered out events are never sent.
    #
    # Example request:
    #
    #   POST https://external-endpoint/api/cdr
    #   Content-Type: application/json
    #   X-Request-Id: 1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed
    #   X-Yeti-Cdr-Batch-Id: 42
    #   X-HMAC-Signature: 6f1d1c6a...
    #
    #   {
    #     "event_bulk_id": "9f2c1e4b8d3a5c7e0f1b2d3a4c5e6f70",
    #     "batch_id": 42,
    #     "data": [
    #       {
    #         "type": "cdr_full",
    #         "payload": {
    #           "id": 12345,
    #           "uuid": "8f14e45f-ceea-467d-9e08-7c1b6c2f1a3e",
    #           "time_start": "2026-06-04T10:15:30.000Z",
    #           "duration": 38,
    #           "success": true,
    #           "customer_price": "0.0190",
    #           "vendor_price": "0.0120"
    #         }
    #       },
    #       {
    #         "type": "cdr_full",
    #         "payload": {
    #           "id": 12346,
    #           "uuid": "c9f0f895-fb98-4b9c-9c5d-2f3b0c1a4d7e",
    #           "time_start": "2026-06-04T10:17:05.000Z",
    #           "duration": 0,
    #           "success": false,
    #           "customer_price": "0.0000",
    #           "vendor_price": "0.0000"
    #         }
    #       }
    #     ]
    #   }
    class CdrHttpBulk < CdrProcessor::Processors::CdrHttpBase
      HMAC_SIGNATURE_HEADER = 'X-HMAC-Signature'
      HMAC_ALGO = 'SHA256'

      # Overrides CdrHttpBase#perform_events because the bulks are built from
      # CdrProcessor::Event objects: both the event id (for event_bulk_id and
      # for the acknowledgement) and the event type (sent as `type`) are needed,
      # while the base implementation maps events down to their data.
      def perform_events(events)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        each_bulk(events) do |bulk|
          # The body is built before #perform_http_request: the HMAC signature
          # is a header calculated over the exact bytes sent, and the request
          # headers are evaluated before the body in CdrHttpBase.
          @request_body = build_request_body(bulk)
          perform_http_request(bulk)
          ack_events(bulk)
        end
      ensure
        @request_body = nil
        @last_perform_group_duration_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000
      end

      # The base implementation sends one request per event, which would reuse
      # the body (and therefore the HMAC signature) built for the last bulk.
      # Bulks are always sent through #perform_events.
      def perform_group(_events)
        raise NotImplementedError, "#{self.class} sends bulks via #perform_events"
      end

      private

      def each_bulk(events)
        events_to_send = events.select { |event| send_event?(event.data) }
        return if events_to_send.empty?

        if bulk_size
          events_to_send.each_slice(bulk_size) { |bulk| yield bulk }
        else
          yield events_to_send
        end
      end

      # nil means no limit - the whole batch is sent as a single request.
      def bulk_size
        return @bulk_size if defined?(@bulk_size)

        size = @params['bulk_size'].to_i
        @bulk_size = size.positive? ? size : nil
      end

      def ack_events(bulk)
        CdrProcessor::CdrDb.pgq_events_done!(consumer_name, @batch_id, bulk.map(&:id))
      end

      def build_request_body(bulk)
        {
          event_bulk_id: event_bulk_id(bulk),
          batch_id: @batch_id,
          data: bulk.map { |event| { type: event.type, payload: permit_field_for(event.data) } }
        }.to_json
      end

      def event_bulk_id(bulk)
        Digest::MD5.hexdigest([@batch_id, *bulk.map(&:id)].join('-'))
      end

      def http_body(_bulk)
        @request_body
      end

      def http_headers
        headers = { 'Content-Type' => 'application/json' }.merge(super)
        headers['X-Yeti-Cdr-Batch-Id'] = @batch_id.to_s
        headers[HMAC_SIGNATURE_HEADER] = hmac_signature if hmac_secret.present?
        headers
      end

      def hmac_secret
        @params['hmac_secret'].to_s
      end

      def hmac_signature
        OpenSSL::HMAC.hexdigest(HMAC_ALGO, hmac_secret, @request_body)
      end
    end
  end
end
