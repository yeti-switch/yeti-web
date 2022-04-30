# frozen_string_literal: true

RSpec.describe 'Export RX streams', type: :feature do
  include_context :login_as_admin

  let!(:item) do
    create :rx_stream
  end

  before do
    visit rtp_rx_streams_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
                         [
                           ['Id', item.id.to_s],
                           ['Time start', item.time_start.to_s],
                           ['Time end', item.time_end.to_s],
                           ['Pop name', item.pop.try(:name)],
                           ['Node name', item.node.try(:name)],
                           ['Gateway name', item.gateway.try(:name)],
                           ['Gateway external', item.gateway_external_id.to_s],
                           ['Local tag', item.local_tag],
                           ['Tx stream', item.tx_stream_id.to_s],
                           ['Rx ssrc', item.rx_ssrc.to_s],
                           ['Remote host', item.remote_host],
                           ['Remote port', item.remote_port.to_s],
                           ['Local host', item.local_host],
                           ['Local port', item.local_port.to_s],
                           ['Rx packets', item.rx_packets.to_s],
                           ['Rx bytes', item.rx_bytes.to_s],
                           ['Rx total lost', item.rx_total_lost.to_s],
                           ['Rx payloads transcoded', item.rx_payloads_transcoded.to_s],
                           ['Rx payloads relayed', item.rx_payloads_relayed.to_s],
                           ['Rx decode errors', item.rx_decode_errors.to_s],
                           ['Rx packet delta min', item.rx_packet_delta_min.to_s],
                           ['Rx packet delta max', item.rx_packet_delta_max.to_s],
                           ['Rx packet delta mean', item.rx_packet_delta_mean.to_s],
                           ['Rx packet delta std', item.rx_packet_delta_std.to_s],
                           ['Rx packet jitter min', item.rx_packet_jitter_min.to_s],
                           ['Rx packet jitter max', item.rx_packet_jitter_max.to_s],
                           ['Rx packet jitter mean', item.rx_packet_jitter_mean.to_s],
                           ['Rx packet jitter std', item.rx_packet_jitter_std.to_s],
                           ['Rx rtcp jitter min', item.rx_rtcp_jitter_min.to_s],
                           ['Rx rtcp jitter max', item.rx_rtcp_jitter_max.to_s],
                           ['Rx rtcp jitter mean', item.rx_rtcp_jitter_mean.to_s],
                           ['Rx rtcp jitter std', item.rx_rtcp_jitter_std.to_s]
                         ]
                       )
  end
end
