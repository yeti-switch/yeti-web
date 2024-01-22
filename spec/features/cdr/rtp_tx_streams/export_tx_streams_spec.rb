# frozen_string_literal: true

RSpec.describe 'Export TX streams', type: :feature do
  include_context :login_as_admin

  let!(:item) do
    create :tx_stream
  end

  before do
    visit rtp_tx_streams_path(format: :csv)
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
                           ['Rtcp rtt min', item.rtcp_rtt_min.to_s],
                           ['Rtcp rtt max', item.rtcp_rtt_max.to_s],
                           ['Rtcp rtt mean', item.rtcp_rtt_mean.to_s],
                           ['Rtcp rtt std', item.rtcp_rtt_std.to_s],
                           ['Rx out of buffer errors', item.rx_out_of_buffer_errors.to_s],
                           ['Rx rtp parse errors', item.rx_rtp_parse_errors.to_s],
                           ['Rx dropped packets', item.rx_dropped_packets.to_s],
                           ['Rx srtp decrypt errors', item.rx_srtp_decrypt_errors.to_s],
                           ['Tx packets', item.tx_packets.to_s],
                           ['Tx bytes', item.tx_bytes.to_s],
                           ['Tx ssrc', item.tx_ssrc.to_s],
                           ['Local host', item.local_host],
                           ['Local port', item.local_port.to_s],
                           ['Tx total lost', item.tx_total_lost.to_s],
                           ['Tx payloads transcoded', item.tx_payloads_transcoded.to_s],
                           ['Tx payloads relayed', item.tx_payloads_relayed.to_s],
                           ['Tx rtcp jitter max', item.tx_rtcp_jitter_min.to_s],
                           ['Tx rtcp jitter min', item.tx_rtcp_jitter_max.to_s],
                           ['Tx rtcp jitter mean', item.tx_rtcp_jitter_mean.to_s],
                           ['Tx rtcp jitter std', item.tx_rtcp_jitter_std.to_s]
                         ]
                       )
  end
end
