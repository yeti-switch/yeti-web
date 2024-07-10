# frozen_string_literal: true

# == Schema Information
#
# Table name: rtp_statistics.rx_streams
#
#  id                     :bigint(8)        not null, primary key
#  local_host             :inet
#  local_port             :integer(4)
#  local_tag              :string
#  remote_host            :inet
#  remote_port            :integer(4)
#  rx_bytes               :bigint(8)
#  rx_decode_errors       :bigint(8)
#  rx_packet_delta_max    :float
#  rx_packet_delta_mean   :float
#  rx_packet_delta_min    :float
#  rx_packet_delta_std    :float
#  rx_packet_jitter_max   :float
#  rx_packet_jitter_mean  :float
#  rx_packet_jitter_min   :float
#  rx_packet_jitter_std   :float
#  rx_packets             :bigint(8)
#  rx_payloads_relayed    :string           is an Array
#  rx_payloads_transcoded :string           is an Array
#  rx_rtcp_jitter_max     :float
#  rx_rtcp_jitter_mean    :float
#  rx_rtcp_jitter_min     :float
#  rx_rtcp_jitter_std     :float
#  rx_ssrc                :bigint(8)
#  rx_total_lost          :bigint(8)
#  time_end               :timestamptz
#  time_start             :timestamptz      not null
#  gateway_external_id    :bigint(8)
#  gateway_id             :bigint(8)
#  node_id                :integer(4)
#  pop_id                 :integer(4)
#  tx_stream_id           :bigint(8)
#
FactoryBot.define do
  factory :rx_stream, class: RtpStatistics::RxStream do
    time_start { 1.minute.ago }
    time_end { 30.seconds.ago }
    association :pop
    association :node
    association :gateway
    gateway_external_id { 11 }

    tx_stream_id { 123 }
    local_tag { SecureRandom.uuid }
    rx_ssrc { 10_002_344 }
    local_host { '1.1.1.1' }
    local_port { 1024 }
    remote_host { '1.1.1.1' }
    remote_port { 2121 }
    rx_packets { 100 }
    rx_bytes { 100 }
    rx_total_lost { 20 }
    rx_payloads_transcoded { %w[PCMU PCMA] }
    rx_payloads_relayed { %w[G729 OPUS] }
    rx_decode_errors { 10 }
    rx_packet_delta_min { 0.000001 }
    rx_packet_delta_max { 0.00009  }
    rx_packet_delta_mean { 0.00008 }
    rx_packet_delta_std { 0.00000000000001 }
    rx_packet_jitter_min { 0.0001 }
    rx_packet_jitter_max { 0.0001 }
    rx_packet_jitter_mean { 0.07700001 }
    rx_packet_jitter_std { 0.00044001 }
    rx_rtcp_jitter_min { 0.00340001 }
    rx_rtcp_jitter_max { 0.00540001 }
    rx_rtcp_jitter_mean { 0.00520001 }
    rx_rtcp_jitter_std { 0.0050001 }

    before(:create) do |record, _evaluator|
      # Create partition for current+next monthes if not exists
      RtpStatistics::RxStream.add_partition_for(record.time_start)
    end
  end
end
