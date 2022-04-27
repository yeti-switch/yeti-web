# frozen_string_literal: true

RSpec.describe 'switch.write_rtp_statistics()' do
  subject do
    SqlCaller::Cdr.execute("SELECT switch.write_rtp_statistics(
      '#{data}'::json,
      #{pop_id},
      #{node_id},
      #{lega_gateway_id},
      #{lega_gateway_external_id},
      #{legb_gateway_id},
      #{legb_gateway_external_id},
      '#{lega_local_tag}',
      '#{legb_local_tag}');")
  end

  let(:pop_id) { 1 }
  let(:node_id) { 2 }
  let(:lega_gateway_id) { 3 }
  let(:lega_gateway_external_id) { 4 }
  let(:legb_gateway_id) { 5 }
  let(:legb_gateway_external_id) { 6 }
  let(:lega_local_tag) { 66 }
  let(:legb_local_tag) { 66 }

  let(:data) do
    '[
   {
      "local_tag":"8-053E9F9A-61A0C677000C790C-DCBDE700",
      "rtcp_rtt_min":0,
      "rtcp_rtt_max":0,
      "rtcp_rtt_mean":0,
      "rtcp_rtt_std":0,
      "time_start":"2022-04-26 13:35:40",
      "time_end":"2022-04-26 13:35:40",
      "rx_out_of_buffer_errors":0,
      "rx_rtp_parse_errors":0,
      "rx_dropped_packets":0,
      "rx":[
         {
            "rx_ssrc":267906310,
            "remote_host":"192.168.240.109",
            "remote_port":40000,
            "rx_packets":1029,
            "rx_bytes":164640,
            "rx_total_lost":0,
            "rx_payloads_transcoded":"g711,g723",
            "rx_payloads_relayed":"pcmu,pcma",
            "rx_decode_errors":0,
            "rx_packet_delta_min":19,
            "rx_packet_delta_max":20,
            "rx_packet_delta_mean":20.000097,
            "rx_packet_delta_std":0.018844,
            "rx_packet_jitter_min":0,
            "rx_packet_jitter_max":0.033933,
            "rx_packet_jitter_mean":0.022334,
            "rx_packet_jitter_std":0.003014,
            "rx_rtcp_jitter_min":0,
            "rx_rtcp_jitter_max":0,
            "rx_rtcp_jitter_mean":0,
            "rx_rtcp_jitter_std":0
         }
      ],
      "tx_packets":5,
      "tx_bytes":300,
      "tx_ssrc":1316747124,
      "local_host":"192.168.240.109",
      "local_port":10048,
      "tx_total_lost":0,
      "tx_payloads_transcoded":"pcma,pcmu",
      "tx_payloads_relayed":"g711,g726",
      "tx_rtcp_jitter_min":0,
      "tx_rtcp_jitter_max":0,
      "tx_rtcp_jitter_mean":0,
      "tx_rtcp_jitter_std":0
   },
   {
      "local_tag":"8-053E9F9A-61A0C677000C790C-DCBDE700",
      "rtcp_rtt_min":0,
      "rtcp_rtt_max":0,
      "rtcp_rtt_mean":0,
      "rtcp_rtt_std":0,
      "time_start":"2022-04-26 13:35:40",
      "time_end":"2022-04-26 13:35:40",
      "rx_out_of_buffer_errors":0,
      "rx_rtp_parse_errors":0,
      "rx_dropped_packets":0,
      "rx":[
         {
            "rx_ssrc":267906310,
            "remote_host":"192.168.240.109",
            "remote_port":40000,
            "rx_packets":1029,
            "rx_bytes":164640,
            "rx_total_lost":0,
            "rx_payloads_transcoded":"",
            "rx_payloads_relayed":"pcmu",
            "rx_decode_errors":0,
            "rx_packet_delta_min":19,
            "rx_packet_delta_max":20,
            "rx_packet_delta_mean":20.000097,
            "rx_packet_delta_std":0.018844,
            "rx_packet_jitter_min":0,
            "rx_packet_jitter_max":0.033933,
            "rx_packet_jitter_mean":0.022334,
            "rx_packet_jitter_std":0.003014,
            "rx_rtcp_jitter_min":0,
            "rx_rtcp_jitter_max":0,
            "rx_rtcp_jitter_mean":0,
            "rx_rtcp_jitter_std":0
         }

      ],
      "tx_packets":0,
      "tx_bytes":0,
      "tx_ssrc":287288557,
      "local_host":"::",
      "local_port":0,
      "tx_total_lost":0,
      "tx_payloads_transcoded":"",
      "tx_payloads_relayed":"",
      "tx_rtcp_jitter_min":0,
      "tx_rtcp_jitter_max":0,
      "tx_rtcp_jitter_mean":0,
      "tx_rtcp_jitter_std":0
   },
   {
      "local_tag":"8-3C5106AE-61A0C677000DA59F-25C20700",
      "rtcp_rtt_min":0,
      "rtcp_rtt_max":0,
      "rtcp_rtt_mean":0,
      "rtcp_rtt_std":0,
      "time_start":"2022-04-26 13:35:20",
      "time_end":"2022-04-26 13:35:40",
      "rx_out_of_buffer_errors":0,
      "rx_rtp_parse_errors":0,
      "rx_dropped_packets":0,
      "rx":[
         {
            "rx_ssrc":1458718330,
            "remote_host":"192.168.240.109",
            "remote_port":40064,
            "rx_packets":3,
            "rx_bytes":480,
            "rx_total_lost":0,
            "rx_payloads_transcoded":"",
            "rx_payloads_relayed":"",
            "rx_decode_errors":0,
            "rx_packet_delta_min":20,
            "rx_packet_delta_max":20,
            "rx_packet_delta_mean":20.003000,
            "rx_packet_delta_std":0,
            "rx_packet_jitter_min":0,
            "rx_packet_jitter_max":0,
            "rx_packet_jitter_mean":0,
            "rx_packet_jitter_std":0,
            "rx_rtcp_jitter_min":0,
            "rx_rtcp_jitter_max":0,
            "rx_rtcp_jitter_mean":0,
            "rx_rtcp_jitter_std":0
         }
      ],
      "tx_packets":1031,
      "tx_bytes":164480,
      "tx_ssrc":1541126890,
      "local_host":"192.168.240.109",
      "local_port":10000,
      "tx_total_lost":0,
      "tx_payloads_transcoded":"",
      "tx_payloads_relayed":"pcmu",
      "tx_rtcp_jitter_min":0,
      "tx_rtcp_jitter_max":0,
      "tx_rtcp_jitter_mean":0,
      "tx_rtcp_jitter_std":0
   },
   {
      "local_tag":"8-3C5106AE-61A0C677000DA59F-25C20700",
      "rtcp_rtt_min":0,
      "rtcp_rtt_max":0,
      "rtcp_rtt_mean":0,
      "rtcp_rtt_std":0,
      "time_start":"2022-04-26 13:35:40",
      "time_end":"2022-04-26 13:35:40",
      "rx_out_of_buffer_errors":0,
      "rx_rtp_parse_errors":0,
      "rx_dropped_packets":0,
      "rx":[
         {
            "rx_ssrc":1458718330,
            "remote_host":"192.168.240.109",
            "remote_port":40064,
            "rx_packets":3,
            "rx_bytes":480,
            "rx_total_lost":0,
            "rx_payloads_transcoded":"",
            "rx_payloads_relayed":"",
            "rx_decode_errors":0,
            "rx_packet_delta_min":20,
            "rx_packet_delta_max":20,
            "rx_packet_delta_mean":20.003000,
            "rx_packet_delta_std":0,
            "rx_packet_jitter_min":0,
            "rx_packet_jitter_max":0,
            "rx_packet_jitter_mean":0,
            "rx_packet_jitter_std":0,
            "rx_rtcp_jitter_min":0,
            "rx_rtcp_jitter_max":0,
            "rx_rtcp_jitter_mean":0,
            "rx_rtcp_jitter_std":0
         }

      ],
      "tx_packets":0,
      "tx_bytes":0,
      "tx_ssrc":1636739746,
      "local_host":"::",
      "local_port":0,
      "tx_total_lost":0,
      "tx_payloads_transcoded":"",
      "tx_payloads_relayed":"",
      "tx_rtcp_jitter_min":0,
      "tx_rtcp_jitter_max":0,
      "tx_rtcp_jitter_mean":0,
      "tx_rtcp_jitter_std":0
   }]'
  end

  it 'creates TX streams' do
    expect { subject }.to change { RtpStatistics::TxStream.count }.by(4)
  end

  it 'creates RX streams' do
    expect { subject }.to change { RtpStatistics::RxStream.count }.by(4)
  end
end
