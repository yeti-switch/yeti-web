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
      '#{legb_local_tag}',
      '#{cdr_time_start.iso8601}'::timestamptz);")
  end

  let(:pop_id) { 1 }
  let(:node_id) { 2 }
  # Passed by writecdr as the CDR time_start; stream rows store it in time_start.
  let(:cdr_time_start) { Time.current.change(hour: 12) }

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

    # tag1 entry from #data (legA: local_tag == lega_local_tag)
    let(:tag1) { JSON.parse(data).find { |s| s['local_tag'] == 'tag1' } }
    let(:tag1_rx) { tag1['rx'].first }

    def be_close_to(expected)
      be_within([expected.abs * 1e-4, 1e-6].max).of(expected)
    end

    it 'maps every TX stream attribute from the input JSON' do
      subject
      tx = RtpStatistics::TxStream.find_by!(local_tag: 'tag1', tx_ssrc: 1_316_747_124)

      aggregate_failures do
        # identity / context
        expect(tx.pop_id).to eq(pop_id)
        expect(tx.node_id).to eq(node_id)
        expect(tx.gateway_id).to eq(lega_gateway_id)
        expect(tx.gateway_external_id).to eq(lega_gateway_external_id)
        expect(tx.local_tag).to eq('tag1')
        # time_start carries the CDR time_start passed by writecdr;
        # the media stream's own times go to stream_time_start/stream_time_end.
        expect(tx.time_start).to be_within(0.001).of(cdr_time_start)
        expect(tx.stream_time_start).to be_within(0.001).of(Time.zone.at(tag1['time_start']))
        expect(tx.stream_time_end).to be_within(0.001).of(Time.zone.at(tag1['time_end']))

        # rtcp rtt (real / float(24))
        expect(tx.rtcp_rtt_min).to be_close_to(tag1['rtcp_rtt_min'])
        expect(tx.rtcp_rtt_max).to be_close_to(tag1['rtcp_rtt_max'])
        expect(tx.rtcp_rtt_mean).to be_close_to(tag1['rtcp_rtt_mean'])
        expect(tx.rtcp_rtt_std).to be_close_to(tag1['rtcp_rtt_std'])

        # rx-side counters are stored on the tx_streams row
        expect(tx.rx_out_of_buffer_errors).to eq(tag1['rx_out_of_buffer_errors'])
        expect(tx.rx_rtp_parse_errors).to eq(tag1['rx_rtp_parse_errors'])
        expect(tx.rx_dropped_packets).to eq(tag1['rx_dropped_packets'])
        expect(tx.rx_srtp_decrypt_errors).to eq(tag1['rx_srtp_decrypt_errors'])

        # tx counters
        expect(tx.tx_packets).to eq(tag1['tx_packets'])
        expect(tx.tx_bytes).to eq(tag1['tx_bytes'])
        expect(tx.tx_ssrc).to eq(tag1['tx_ssrc'])
        expect(tx.tx_total_lost).to eq(tag1['tx_total_lost'])

        # local socket
        expect(tx.local_host.to_s).to eq(tag1['local_host'])
        expect(tx.local_port).to eq(tag1['local_port'])

        # payload lists (comma string -> text[])
        expect(tx.tx_payloads_transcoded).to eq(tag1['tx_payloads_transcoded'].split(','))
        expect(tx.tx_payloads_relayed).to eq(tag1['tx_payloads_relayed'].split(','))

        # tx rtcp jitter
        expect(tx.tx_rtcp_jitter_min).to be_close_to(tag1['tx_rtcp_jitter_min'])
        expect(tx.tx_rtcp_jitter_max).to be_close_to(tag1['tx_rtcp_jitter_max'])
        expect(tx.tx_rtcp_jitter_mean).to be_close_to(tag1['tx_rtcp_jitter_mean'])
        expect(tx.tx_rtcp_jitter_std).to be_close_to(tag1['tx_rtcp_jitter_std'])
      end
    end

    it 'maps every RX stream attribute from the input JSON' do
      subject
      tx = RtpStatistics::TxStream.find_by!(local_tag: 'tag1', tx_ssrc: 1_316_747_124)
      rx = RtpStatistics::RxStream.find_by!(local_tag: 'tag1', rx_ssrc: 267_906_310)

      aggregate_failures do
        # identity / context (inherited from the parent TX stream)
        expect(rx.tx_stream_id).to eq(tx.id)
        expect(rx.pop_id).to eq(pop_id)
        expect(rx.node_id).to eq(node_id)
        expect(rx.gateway_id).to eq(lega_gateway_id)
        expect(rx.gateway_external_id).to eq(lega_gateway_external_id)
        expect(rx.local_tag).to eq('tag1')
        # RX inherits the CDR time_start from its TX stream; media times
        # land in stream_time_start/stream_time_end.
        expect(rx.time_start).to be_within(0.001).of(cdr_time_start)
        expect(rx.stream_time_start).to be_within(0.001).of(Time.zone.at(tag1['time_start']))
        expect(rx.stream_time_end).to be_within(0.001).of(Time.zone.at(tag1['time_end']))

        # local socket comes from the TX stream
        expect(rx.local_host.to_s).to eq(tag1['local_host'])
        expect(rx.local_port).to eq(tag1['local_port'])

        # remote socket comes from the rx element
        expect(rx.remote_host.to_s).to eq(tag1_rx['remote_host'])
        expect(rx.remote_port).to eq(tag1_rx['remote_port'])

        # rx counters
        expect(rx.rx_ssrc).to eq(tag1_rx['rx_ssrc'])
        expect(rx.rx_packets).to eq(tag1_rx['rx_packets'])
        expect(rx.rx_bytes).to eq(tag1_rx['rx_bytes'])
        expect(rx.rx_total_lost).to eq(tag1_rx['rx_total_lost'])
        expect(rx.rx_decode_errors).to eq(tag1_rx['rx_decode_errors'])

        # payload lists (comma string -> text[])
        expect(rx.rx_payloads_transcoded).to eq(tag1_rx['rx_payloads_transcoded'].split(','))
        expect(rx.rx_payloads_relayed).to eq(tag1_rx['rx_payloads_relayed'].split(','))

        # rx packet delta (real / float(24))
        expect(rx.rx_packet_delta_min).to be_close_to(tag1_rx['rx_packet_delta_min'])
        expect(rx.rx_packet_delta_max).to be_close_to(tag1_rx['rx_packet_delta_max'])
        expect(rx.rx_packet_delta_mean).to be_close_to(tag1_rx['rx_packet_delta_mean'])
        expect(rx.rx_packet_delta_std).to be_close_to(tag1_rx['rx_packet_delta_std'])

        # rx packet jitter
        expect(rx.rx_packet_jitter_min).to be_close_to(tag1_rx['rx_packet_jitter_min'])
        expect(rx.rx_packet_jitter_max).to be_close_to(tag1_rx['rx_packet_jitter_max'])
        expect(rx.rx_packet_jitter_mean).to be_close_to(tag1_rx['rx_packet_jitter_mean'])
        expect(rx.rx_packet_jitter_std).to be_close_to(tag1_rx['rx_packet_jitter_std'])

        # rx rtcp jitter
        expect(rx.rx_rtcp_jitter_min).to be_close_to(tag1_rx['rx_rtcp_jitter_min'])
        expect(rx.rx_rtcp_jitter_max).to be_close_to(tag1_rx['rx_rtcp_jitter_max'])
        expect(rx.rx_rtcp_jitter_mean).to be_close_to(tag1_rx['rx_rtcp_jitter_mean'])
        expect(rx.rx_rtcp_jitter_std).to be_close_to(tag1_rx['rx_rtcp_jitter_std'])
      end
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
