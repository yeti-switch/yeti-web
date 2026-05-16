# frozen_string_literal: true

module Cdr
  # Gathers RTP stream data for a CDR so the client can render the diagram.
  # Returns a plain hash that becomes the JSON payload for /cdrs/:id/rtp_diagram.
  #
  # The stream payloads carry every column shown on the RtpRxStreams /
  # RtpTxStreams admin pages (plus the gateway/pop/node display names) so the
  # diagram's detail panel can show the full record with matching labels.
  class BuildRtpDiagram < ApplicationService
    parameter :cdr, required: true

    # Full RX column set (order mirrors the RtpRxStreams show page).
    RX_STREAM_FIELDS = %i[
      id tx_stream_id local_tag time_start stream_time_start stream_time_end
      gateway_external_id rx_ssrc remote_host remote_port
      local_host local_port rx_packets rx_bytes rx_total_lost
      rx_payloads_transcoded rx_payloads_relayed rx_decode_errors
      rx_packet_delta_min rx_packet_delta_max rx_packet_delta_mean rx_packet_delta_std
      rx_packet_jitter_min rx_packet_jitter_max rx_packet_jitter_mean rx_packet_jitter_std
      rx_rtcp_jitter_min rx_rtcp_jitter_max rx_rtcp_jitter_mean rx_rtcp_jitter_std
      gateway_id
    ].freeze

    # Full TX column set (order mirrors the RtpTxStreams show page).
    TX_STREAM_FIELDS = %i[
      id local_tag time_start stream_time_start stream_time_end
      rtcp_rtt_min rtcp_rtt_max rtcp_rtt_mean rtcp_rtt_std
      rx_out_of_buffer_errors rx_rtp_parse_errors rx_dropped_packets rx_srtp_decrypt_errors
      tx_packets tx_bytes tx_ssrc local_host local_port tx_total_lost
      tx_payloads_transcoded tx_payloads_relayed
      tx_rtcp_jitter_min tx_rtcp_jitter_max tx_rtcp_jitter_mean tx_rtcp_jitter_std
      gateway_id
    ].freeze

    def call
      {
        attempts: attempts.map { |a| serialize_attempt(a) },
        rx_streams: rx_streams.map { |s| serialize_stream(s, RX_STREAM_FIELDS) },
        tx_streams: tx_streams.map { |s| serialize_stream(s, TX_STREAM_FIELDS) }
      }
    end

    private

    def attempts
      @attempts ||= cdr.attempts.preload(:orig_gw, :term_gw).to_a
    end

    def all_tags
      attempts.flat_map { |a| [a.local_tag, a.legb_local_tag] }.compact.uniq
    end

    # All routing attempts of a call share the same time_start, and the
    # writecdr SP now stores that exact CDR time_start on every rx/tx stream
    # (stream's own times live in stream_time_start/stream_time_end). So this
    # is an exact-equality set — one value in practice — which lets Postgres
    # prune to a single day partition instead of scanning a padded range.
    def stream_time_starts
      attempts.map(&:time_start).compact.uniq
    end

    def rx_streams
      @rx_streams ||= load_streams(RtpStatistics::RxStream)
    end

    def tx_streams
      @tx_streams ||= load_streams(RtpStatistics::TxStream)
    end

    def load_streams(model)
      return [] if all_tags.empty? || stream_time_starts.empty?

      model.where(local_tag: all_tags, time_start: stream_time_starts)
           .preload(:gateway, :pop, :node).to_a
    end

    def serialize_attempt(a)
      {
        id: a.id,
        routing_attempt: a.routing_attempt,
        local_tag: a.local_tag,
        legb_local_tag: a.legb_local_tag,
        is_last_cdr: a.is_last_cdr,
        orig_gw: serialize_gateway(a.orig_gw),
        term_gw: serialize_gateway(a.term_gw)
      }
    end

    def serialize_gateway(gw)
      return nil if gw.nil?

      { id: gw.id, name: gw.name }
    end

    # Every column the field list names, plus the association display names
    # (gateway/pop/node) so the panel matches the admin show pages.
    def serialize_stream(s, fields)
      h = fields.each_with_object({}) { |f, acc| acc[f] = read(s, f) }
      h[:gateway] = s.gateway&.name
      h[:pop] = s.pop&.name
      h[:node] = s.node&.name
      h
    end

    def read(stream, field)
      value = stream.public_send(field)
      # Cast IPAddr (postgres inet) to a plain string so JSON renders cleanly.
      value.respond_to?(:to_s) && value.is_a?(IPAddr) ? value.to_s : value
    end
  end
end
