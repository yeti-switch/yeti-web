# frozen_string_literal: true

FactoryBot.define do
  factory :rtp_statistic, class: Cdr::RtpStatistic do
    time_start              { 1.minute.ago }
    time_end                { 30.seconds.ago }
    association :pop
    association :node
    association :gateway
    local_tag               { SecureRandom.uuid }
    rtcp_rtt_min            { 0.11 }
    rtcp_rtt_max            { 0.22 }
    rtcp_rtt_mean           { 0.16 }
    rtcp_rtt_std            { 0.17 }
    rx_rtcp_rr_count        { 100 }
    rx_rtcp_sr_count        { 105 }
    tx_rtcp_rr_count        { 100 }
    tx_rtcp_sr_count        { 105 }
    local_host              { '1.1.1.1' }
    local_port              { 6993 }
    remote_host             { '8.8.8.8' }
    remote_port             { 10_050 }
    rx_ssrc                 { 10_002_344 }
    rx_packets              { 10_000 }
    rx_bytes                { 1_232_323 }
    rx_total_lost           { 10 }
    rx_payloads_transcoded  { 'PCMU' }
    rx_payloads_relayed     { 'PCMA' }
    rx_decode_errors        { 14_332 }
    rx_out_of_buffer_errors { 11 }
    rx_rtp_parse_errors     { 44 }
    rx_packet_delta_min     { 0.33 }
    rx_packet_delta_max     { 0.45 }
    rx_packet_delta_mean    { 0.38 }
    rx_packet_delta_std     { 0.37 }
    rx_packet_jitter_min    { 11 }
    rx_packet_jitter_max    { 45 }
    rx_packet_jitter_mean   { 32 }
    rx_packet_jitter_std    { 31 }
    rx_rtcp_jitter_min      { 11 }
    rx_rtcp_jitter_max      { 150 }
    rx_rtcp_jitter_mean     { 50 }
    rx_rtcp_jitter_std      { 53 }
    tx_ssrc                 { 11_111_111 }
    tx_packets              { 1_004_304 }
    tx_bytes                { 3_420_000 }
    tx_total_lost           { 2342 }
    tx_payloads_transcoded  { 'PCMA' }
    tx_payloads_relayed     { 'opus' }
    tx_rtcp_jitter_min      { 10 }
    tx_rtcp_jitter_max      { 80 }
    tx_rtcp_jitter_mean     { 39 }
    tx_rtcp_jitter_std      { 40 }

    before(:create) do |record, _evaluator|
      # Create partition for current+next monthes if not exists
      Cdr::RtpStatistic.add_partition_for(record.time_start)
    end
  end
end
