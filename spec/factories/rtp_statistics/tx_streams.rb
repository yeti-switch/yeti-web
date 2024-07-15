# frozen_string_literal: true

# == Schema Information
#
# Table name: rtp_statistics.tx_streams
#
#  id                      :bigint(8)        not null, primary key
#  local_host              :inet
#  local_port              :integer(4)
#  local_tag               :string           not null
#  rtcp_rtt_max            :float
#  rtcp_rtt_mean           :float
#  rtcp_rtt_min            :float
#  rtcp_rtt_std            :float
#  rx_dropped_packets      :bigint(8)
#  rx_out_of_buffer_errors :bigint(8)
#  rx_rtp_parse_errors     :bigint(8)
#  rx_srtp_decrypt_errors  :bigint(8)
#  time_end                :timestamptz
#  time_start              :timestamptz      not null
#  tx_bytes                :bigint(8)
#  tx_packets              :bigint(8)
#  tx_payloads_relayed     :string           is an Array
#  tx_payloads_transcoded  :string           is an Array
#  tx_rtcp_jitter_max      :float
#  tx_rtcp_jitter_mean     :float
#  tx_rtcp_jitter_min      :float
#  tx_rtcp_jitter_std      :float
#  tx_ssrc                 :bigint(8)
#  tx_total_lost           :integer(4)
#  gateway_external_id     :bigint(8)
#  gateway_id              :bigint(8)
#  node_id                 :integer(4)
#  pop_id                  :integer(4)
#
FactoryBot.define do
  factory :tx_stream, class: 'RtpStatistics::TxStream' do
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
      RtpStatistics::TxStream.add_partition_for(record.time_start)
    end
  end
end
