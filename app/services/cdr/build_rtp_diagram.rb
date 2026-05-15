# frozen_string_literal: true

module Cdr
  # Gathers RTP stream data for a CDR so the client can render the diagram.
  # Returns a plain hash that becomes the JSON payload for /cdrs/:id/rtp_diagram.
  class BuildRtpDiagram < ApplicationService
    parameter :cdr, required: true

    STREAM_FIELDS_COMMON = %i[
      id local_tag gateway_id time_start time_end
      local_host local_port
    ].freeze

    RX_STREAM_FIELDS = STREAM_FIELDS_COMMON + %i[
      remote_host remote_port rx_ssrc rx_packets rx_bytes rx_total_lost
      rx_packet_jitter_mean rx_packet_jitter_max rx_decode_errors
    ]

    TX_STREAM_FIELDS = STREAM_FIELDS_COMMON + %i[
      tx_ssrc tx_packets tx_bytes tx_total_lost
      tx_rtcp_jitter_mean rtcp_rtt_mean rtcp_rtt_max
    ]

    def call
      {
        attempts: attempts.map { |a| serialize_attempt(a) },
        rx_streams: rx_streams.map { |s| serialize_rx(s) },
        tx_streams: tx_streams.map { |s| serialize_tx(s) }
      }
    end

    private

    def attempts
      @attempts ||= cdr.attempts.preload(:orig_gw, :term_gw).to_a
    end

    def all_tags
      attempts.flat_map { |a| [a.local_tag, a.legb_local_tag] }.compact.uniq
    end

    def time_range
      starts = attempts.map(&:time_start).compact
      ends = attempts.map { |a| a.time_end || a.time_start }.compact
      return nil if starts.empty? || all_tags.empty?

      (starts.min - 300)..(ends.max + 300)
    end

    def rx_streams
      @rx_streams ||= time_range ? RtpStatistics::RxStream.where(local_tag: all_tags, time_start: time_range).to_a : []
    end

    def tx_streams
      @tx_streams ||= time_range ? RtpStatistics::TxStream.where(local_tag: all_tags, time_start: time_range).to_a : []
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

    def serialize_rx(s)
      RX_STREAM_FIELDS.each_with_object({}) { |f, h| h[f] = read(s, f) }
    end

    def serialize_tx(s)
      TX_STREAM_FIELDS.each_with_object({}) { |f, h| h[f] = read(s, f) }
    end

    def read(stream, field)
      value = stream.public_send(field)
      # Cast IPAddr (postgres inet) to a plain string so JSON renders cleanly.
      value.respond_to?(:to_s) && value.is_a?(IPAddr) ? value.to_s : value
    end
  end
end
