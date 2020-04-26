# frozen_string_literal: true

require 'spec_helper'

describe 'Export RTP statistics', type: :feature do
  include_context :login_as_admin

  #before { create(:gateway) }

  let!(:item) do
    create :rtp_statistic
  end

  before do
    visit rtp_statistics_path(format: :csv)
  end

  subject {CSV.parse(page.body).slice(0, 2).transpose}

  it 'has expected header and values' do
    expect(subject).to match_array(
                           [
                               ['Id', item.id.to_s],
                               ['Time start', item.time_start.to_s],
                               ['Time end', item.time_end.to_s],
                               ['Pop name', item.pop.try(:name)],
                               ['Node name', item.node.try(:name)],
                               ['Gateway name', item.gateway.try(:name)],
                               ['Gateway external', item.gateway.try(:external_id).to_s],
                               ['Local tag', item.local_tag],
                               ['Rtcp rtt min',item.rtcp_rtt_min.to_s],
                               ['Rtcp rtt max',item.rtcp_rtt_max.to_s],
                               ['Rtcp rtt mean',item.rtcp_rtt_mean.to_s],
                               ['Rtcp rtt std',item.rtcp_rtt_std.to_s],
                               ['Rx rtcp rr count',item.rx_rtcp_rr_count.to_s],
                               ['Rx rtcp sr count',item.rx_rtcp_sr_count.to_s],
                               ['Tx rtcp rr count',item.tx_rtcp_rr_count.to_s],
                               ['Tx rtcp sr count',item.tx_rtcp_sr_count.to_s],
                               ['Local host',item.local_host.to_s],
                               ['Local port',item.local_port.to_s],
                               ['Remote host',item.remote_host.to_s],
                               ['Remote port',item.remote_port.to_s],
                               ['Rx ssrc',item.rx_ssrc.to_s],
                               ['Rx packets',item.rx_packets.to_s],
                               ['Rx bytes',item.rx_bytes.to_s],
                               ['Rx total lost',item.rx_total_lost.to_s],
                               ['Rx payloads transcoded',item.rx_payloads_transcoded.to_s],
                               ['Rx payloads relayed',item.rx_payloads_relayed.to_s],
                               ['Rx decode errors',item.rx_decode_errors.to_s],
                               ['Rx out of buffer errors', item.rx_out_of_buffer_errors.to_s],
                               ['Rx rtp parse errors',item.rx_rtp_parse_errors.to_s],
                               ['Rx packet delta min',item.rx_packet_delta_min.to_s],
                               ['Rx packet delta max',item.rx_packet_delta_max.to_s],
                               ['Rx packet delta mean',item.rx_packet_delta_mean.to_s],
                               ['Rx packet delta std',item.rx_packet_delta_std.to_s],
                               ['Rx packet jitter min',item.rx_packet_jitter_min.to_s],
                               ['Rx packet jitter max',item.rx_packet_jitter_max.to_s],
                               ['Rx packet jitter mean',item.rx_packet_jitter_mean.to_s],
                               ['Rx packet jitter std',item.rx_packet_jitter_std.to_s],
                               ['Rx rtcp jitter min',item.rx_rtcp_jitter_min.to_s],
                               ['Rx rtcp jitter max',item.rx_rtcp_jitter_max.to_s],
                               ['Rx rtcp jitter mean',item.rx_rtcp_jitter_mean.to_s],
                               ['Rx rtcp jitter std',item.rx_rtcp_jitter_std.to_s],
                               ['Tx ssrc',item.tx_ssrc.to_s],
                               ['Tx packets',item.tx_packets.to_s],
                               ['Tx bytes',item.tx_bytes.to_s],
                               ['Tx total lost',item.tx_total_lost.to_s],
                               ['Tx payloads transcoded',item.tx_payloads_transcoded.to_s],
                               ['Tx payloads relayed',item.tx_payloads_relayed.to_s],
                               ['Tx rtcp jitter min',item.tx_rtcp_jitter_min.to_s],
                               ['Tx rtcp jitter max',item.tx_rtcp_jitter_max.to_s],
                               ['Tx rtcp jitter mean',item.tx_rtcp_jitter_mean.to_s],
                               ['Tx rtcp jitter std',item.tx_rtcp_jitter_std.to_s]
                           ]
                       )
  end
end
