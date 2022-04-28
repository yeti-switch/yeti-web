# frozen_string_literal: true

FactoryBot.define do
  factory :tx_stream, class: RtpStatistics::TxStream do
    time_start { 1.minute.ago }
    time_end { 30.seconds.ago }
    association :pop
    association :node
    association :gateway
    gateway_external_id { 11 }
    local_tag { SecureRandom.uuid }

    rtcp_rtt_min { 0.000001 }
    rtcp_rtt_max { 0.000001 }
    rtcp_rtt_mean { 0.000001 }
    rtcp_rtt_std { 0.000001 }
    rx_out_of_buffer_errors { 100 }
    rx_rtp_parse_errors { 100 }
    rx_dropped_packets { 100 }
    tx_packets { 100 }
    tx_bytes { 100 }
    tx_ssrc { 10_023_323 }
    local_host { '1.2.3.4' }
    local_port { 65_535 }
    tx_total_lost { 100 }
    tx_payloads_transcoded { %w[pcmu pcma] }
    tx_payloads_relayed { ['opus'] }
    tx_rtcp_jitter_min { 0.000001 }
    tx_rtcp_jitter_max { 0.000001 }
    tx_rtcp_jitter_mean { 0.000001 }
    tx_rtcp_jitter_std { 0.000001 }

    before(:create) do |record, _evaluator|
      # Create partition for current+next monthes if not exists
      RtpStatistics.TxStream.add_partition_for(record.time_start)
    end
  end
end
