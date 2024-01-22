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

  let(:data) do
    [
      {
        "local_tag": 'tag1',
        "rtcp_rtt_min": 0.766767454435456456,
        "rtcp_rtt_max": 0.2323234232565656,
        "rtcp_rtt_mean": 0.67676767566,
        "rtcp_rtt_std": 0.76767676,
        "time_start": 10.seconds.ago.to_f,
        "time_end": Time.now.to_f,
        "rx_out_of_buffer_errors": 1,
        "rx_rtp_parse_errors": 12,
        "rx_dropped_packets": 11,
        "rx_srtp_decrypt_errors": 150,
        "rx": [
          {
            "rx_ssrc": 267_906_310,
            "remote_host": '192.168.240.109',
            "remote_port": 40_000,
            "rx_packets": 1029,
            "rx_bytes": 164_640,
            "rx_total_lost": 0,
            "rx_payloads_transcoded": 'g711,g723',
            "rx_payloads_relayed": 'pcmu,pcma',
            "rx_decode_errors": 0,
            "rx_packet_delta_min": 19.9999999999999999999999999,
            "rx_packet_delta_max": 20.9999999999999999999999,
            "rx_packet_delta_mean": 20.00999999990097,
            "rx_packet_delta_std": 0.0189999999999999844,
            "rx_packet_jitter_min": 0,
            "rx_packet_jitter_max": 0.033933,
            "rx_packet_jitter_mean": 0.022334,
            "rx_packet_jitter_std": 0.003014,
            "rx_rtcp_jitter_min": 0,
            "rx_rtcp_jitter_max": 0,
            "rx_rtcp_jitter_mean": 0,
            "rx_rtcp_jitter_std": 0
          }
        ],
        "tx_packets": 5,
        "tx_bytes": 300,
        "tx_ssrc": 1_316_747_124,
        "local_host": '192.168.240.109',
        "local_port": 10_048,
        "tx_total_lost": 0,
        "tx_payloads_transcoded": 'pcma,pcmu',
        "tx_payloads_relayed": 'g711,g726',
        "tx_rtcp_jitter_min": 0,
        "tx_rtcp_jitter_max": 0,
        "tx_rtcp_jitter_mean": 0,
        "tx_rtcp_jitter_std": 0
      },
      {
        "local_tag": 'tag2',
        "rtcp_rtt_min": 0,
        "rtcp_rtt_max": 0,
        "rtcp_rtt_mean": 0,
        "rtcp_rtt_std": 0,
        "time_start": 10.seconds.ago.to_f,
        "time_end": Time.now.to_f,
        "rx_out_of_buffer_errors": 0,
        "rx_rtp_parse_errors": 0,
        "rx_dropped_packets": 0,
        "rx_srtp_decrypt_errors": 10,
        "rx": [
          {
            "rx_ssrc": 267_906_310,
            "remote_host": '192.168.240.109',
            "remote_port": 40_000,
            "rx_packets": 1029,
            "rx_bytes": 164_640,
            "rx_total_lost": 0,
            "rx_payloads_transcoded": '',
            "rx_payloads_relayed": 'pcmu',
            "rx_decode_errors": 0,
            "rx_packet_delta_min": 19,
            "rx_packet_delta_max": 20,
            "rx_packet_delta_mean": 20.000097,
            "rx_packet_delta_std": 0.018844,
            "rx_packet_jitter_min": 0,
            "rx_packet_jitter_max": 0.033933,
            "rx_packet_jitter_mean": 0.022334,
            "rx_packet_jitter_std": 0.003014,
            "rx_rtcp_jitter_min": 0,
            "rx_rtcp_jitter_max": 0,
            "rx_rtcp_jitter_mean": 0,
            "rx_rtcp_jitter_std": 0
          }

        ],
        "tx_packets": 0,
        "tx_bytes": 0,
        "tx_ssrc": 287_288_557,
        "local_host": '::',
        "local_port": 0,
        "tx_total_lost": 0,
        "tx_payloads_transcoded": '',
        "tx_payloads_relayed": '',
        "tx_rtcp_jitter_min": 0,
        "tx_rtcp_jitter_max": 0,
        "tx_rtcp_jitter_mean": 0,
        "tx_rtcp_jitter_std": 0
      },
      {
        "local_tag": 'tag3',
        "rtcp_rtt_min": 0,
        "rtcp_rtt_max": 0,
        "rtcp_rtt_mean": 0,
        "rtcp_rtt_std": 0,
        "time_start": 10.seconds.ago.to_f,
        "time_end": Time.now.to_f,
        "rx_out_of_buffer_errors": 0,
        "rx_rtp_parse_errors": 0,
        "rx_dropped_packets": 0,
        "rx_srtp_decrypt_errors": 8,
        "rx": [
          {
            "rx_ssrc": 1_458_718_330,
            "remote_host": '192.168.240.109',
            "remote_port": 40_064,
            "rx_packets": 3,
            "rx_bytes": 480,
            "rx_total_lost": 0,
            "rx_payloads_transcoded": '',
            "rx_payloads_relayed": '',
            "rx_decode_errors": 0,
            "rx_packet_delta_min": 20,
            "rx_packet_delta_max": 20,
            "rx_packet_delta_mean": 20.003000,
            "rx_packet_delta_std": 0,
            "rx_packet_jitter_min": 0,
            "rx_packet_jitter_max": 0,
            "rx_packet_jitter_mean": 0,
            "rx_packet_jitter_std": 0,
            "rx_rtcp_jitter_min": 0,
            "rx_rtcp_jitter_max": 0,
            "rx_rtcp_jitter_mean": 0,
            "rx_rtcp_jitter_std": 0
          }
        ],
        "tx_packets": 1031,
        "tx_bytes": 164_480,
        "tx_ssrc": 1_541_126_890,
        "local_host": '192.168.240.109',
        "local_port": 10_000,
        "tx_total_lost": 0,
        "tx_payloads_transcoded": '',
        "tx_payloads_relayed": 'pcmu',
        "tx_rtcp_jitter_min": 0,
        "tx_rtcp_jitter_max": 0,
        "tx_rtcp_jitter_mean": 0,
        "tx_rtcp_jitter_std": 0
      },
      {
        "local_tag": 'tag4',
        "rtcp_rtt_min": 0,
        "rtcp_rtt_max": 0,
        "rtcp_rtt_mean": 0,
        "rtcp_rtt_std": 0,
        "time_start": 10.seconds.ago.to_f,
        "time_end": Time.now.to_f,
        "rx_out_of_buffer_errors": 0,
        "rx_rtp_parse_errors": 0,
        "rx_dropped_packets": 0,
        "rx_srtp_decrypt_errors": 1,
        "rx": [
          {
            "rx_ssrc": 1_458_718_330,
            "remote_host": '192.168.240.109',
            "remote_port": 40_064,
            "rx_packets": 3,
            "rx_bytes": 480,
            "rx_total_lost": 0,
            "rx_payloads_transcoded": '',
            "rx_payloads_relayed": '',
            "rx_decode_errors": 0,
            "rx_packet_delta_min": 20,
            "rx_packet_delta_max": 20,
            "rx_packet_delta_mean": 20.003000,
            "rx_packet_delta_std": 0,
            "rx_packet_jitter_min": 0,
            "rx_packet_jitter_max": 0,
            "rx_packet_jitter_mean": 0,
            "rx_packet_jitter_std": 0,
            "rx_rtcp_jitter_min": 0,
            "rx_rtcp_jitter_max": 0,
            "rx_rtcp_jitter_mean": 0,
            "rx_rtcp_jitter_std": 0
          }

        ],
        "tx_packets": 0,
        "tx_bytes": 0,
        "tx_ssrc": 1_636_739_746,
        "local_host": '::',
        "local_port": 0,
        "tx_total_lost": 0,
        "tx_payloads_transcoded": '',
        "tx_payloads_relayed": '',
        "tx_rtcp_jitter_min": 0,
        "tx_rtcp_jitter_max": 0,
        "tx_rtcp_jitter_mean": 0,
        "tx_rtcp_jitter_std": 0
      }
    ].to_json
  end

  context 'Known tags' do
    let(:lega_local_tag) { 'tag1' }
    let(:legb_local_tag) { 'tag2' }
    let(:lega_gateway_id) { 1 }
    let(:lega_gateway_external_id) { 11 }
    let(:legb_gateway_id) { 2 }
    let(:legb_gateway_external_id) { 22 }

    it 'creates TX streams with known tags' do
      expect { subject }.to change { RtpStatistics::TxStream.count }.by(4)
    end
    it 'creates RX streams with known tags' do
      expect { subject }.to change { RtpStatistics::RxStream.count }.by(4)
    end
  end

  context 'Unknown tags' do
    let(:lega_local_tag) { 'tag100' }
    let(:legb_local_tag) { 'tag200' }
    let(:lega_gateway_id) { 1 }
    let(:lega_gateway_external_id) { 11 }
    let(:legb_gateway_id) { 2 }
    let(:legb_gateway_external_id) { 22 }

    it 'creates TX streams with known tags' do
      expect { subject }.to change { RtpStatistics::TxStream.count }.by(4)
    end
    it 'creates RX streams with known tags' do
      expect { subject }.to change { RtpStatistics::RxStream.count }.by(4)
    end
  end
end
