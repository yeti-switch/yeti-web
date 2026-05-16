# frozen_string_literal: true

RSpec.describe Cdr::BuildRtpDiagram do
  subject { described_class.call(cdr: cdr) }

  let(:time_start) { 1.hour.ago }
  let(:lega_tag) { 'lega-tag-abc' }
  let(:legb_tag_attempt1) { 'legb-tag-1' }
  let(:legb_tag_attempt2) { 'legb-tag-2' }

  let!(:orig_gw) { FactoryBot.create(:gateway, name: 'Orig-A') }
  let!(:term_gw1) { FactoryBot.create(:gateway, name: 'Term-1') }
  let!(:term_gw2) { FactoryBot.create(:gateway, name: 'Term-2') }

  let!(:attempt1) do
    FactoryBot.create(:cdr,
                      time_start: time_start, local_tag: lega_tag,
                      legb_local_tag: legb_tag_attempt1,
                      orig_gw_id: orig_gw.id, term_gw_id: term_gw1.id,
                      routing_attempt: 1, is_last_cdr: false, success: false)
  end
  let!(:cdr) do
    FactoryBot.create(:cdr,
                      time_start: time_start, local_tag: lega_tag,
                      legb_local_tag: legb_tag_attempt2,
                      orig_gw_id: orig_gw.id, term_gw_id: term_gw2.id,
                      routing_attempt: 2, is_last_cdr: true)
  end

  let!(:lega_rx1) do
    FactoryBot.create(:rx_stream, local_tag: lega_tag, gateway: orig_gw, rx_ssrc: 0xAA11,
                                  local_host: '10.0.0.1', local_port: 30_001,
                                  remote_host: '203.0.113.10', remote_port: 40_010,
                                  time_start: time_start, rx_packets: 1000, rx_bytes: 80_000)
  end
  let!(:lega_tx) do
    FactoryBot.create(:tx_stream, local_tag: lega_tag, gateway: orig_gw, tx_ssrc: 0xBB11,
                                  local_host: '10.0.0.1', local_port: 30_002,
                                  time_start: time_start, tx_packets: 1010, tx_bytes: 81_000)
  end
  let!(:legb_rx_attempt1) do
    FactoryBot.create(:rx_stream, local_tag: legb_tag_attempt1, gateway: term_gw1,
                                  time_start: time_start, rx_packets: 0, rx_bytes: 0)
  end
  let!(:legb_rx_attempt2) do
    FactoryBot.create(:rx_stream, local_tag: legb_tag_attempt2, gateway: term_gw2,
                                  time_start: time_start, rx_packets: 900, rx_bytes: 72_000)
  end
  let!(:legb_tx_attempt2) do
    FactoryBot.create(:tx_stream, local_tag: legb_tag_attempt2, gateway: term_gw2,
                                  time_start: time_start, tx_packets: 910, tx_bytes: 73_000)
  end

  it 'returns one attempt per cdr row' do
    expect(subject[:attempts].map { |a| a[:id] }).to contain_exactly(attempt1.id, cdr.id)
  end

  it 'embeds orig and term gateway summaries on each attempt' do
    last_attempt = subject[:attempts].find { |a| a[:id] == cdr.id }
    expect(last_attempt[:orig_gw]).to include(id: orig_gw.id, name: 'Orig-A')
    expect(last_attempt[:term_gw]).to include(id: term_gw2.id, name: 'Term-2')
    expect(last_attempt[:legb_local_tag]).to eq(legb_tag_attempt2)
  end

  it 'returns rx_streams with full per-stream fields' do
    rx = subject[:rx_streams].find { |s| s[:id] == lega_rx1.id }
    expect(rx).to include(
      local_tag: lega_tag,
      gateway_id: orig_gw.id,
      rx_ssrc: 0xAA11,
      rx_packets: 1000,
      rx_bytes: 80_000,
      remote_host: '203.0.113.10',
      remote_port: 40_010,
      local_host: '10.0.0.1',
      local_port: 30_001
    )
  end

  it 'returns tx_streams with full per-stream fields (no remote socket)' do
    tx = subject[:tx_streams].find { |s| s[:id] == lega_tx.id }
    expect(tx).to include(
      local_tag: lega_tag,
      gateway_id: orig_gw.id,
      tx_ssrc: 0xBB11,
      tx_packets: 1010,
      tx_bytes: 81_000,
      local_host: '10.0.0.1',
      local_port: 30_002
    )
    expect(tx).not_to have_key(:remote_host)
  end

  it 'exposes the receive-side error counters carried on the TX stream' do
    tx = subject[:tx_streams].find { |s| s[:id] == lega_tx.id }
    expect(tx).to include(
      rx_out_of_buffer_errors: 100,
      rx_rtp_parse_errors: 100,
      rx_dropped_packets: 100
    )
    expect(tx).to have_key(:rx_srtp_decrypt_errors)
  end

  it 'serializes the full RX column set plus gateway/pop/node names' do
    rx = subject[:rx_streams].find { |s| s[:id] == lega_rx1.id }
    Cdr::BuildRtpDiagram::RX_STREAM_FIELDS.each { |f| expect(rx).to have_key(f) }
    expect(rx).to include(gateway: orig_gw.name)
    expect(rx).to have_key(:pop)
    expect(rx).to have_key(:node)
    expect(rx).to have_key(:tx_stream_id)
    expect(rx).to have_key(:rx_packet_delta_min)
    expect(rx).to have_key(:rx_rtcp_jitter_std)
  end

  it 'serializes the full TX column set plus gateway/pop/node names' do
    tx = subject[:tx_streams].find { |s| s[:id] == lega_tx.id }
    Cdr::BuildRtpDiagram::TX_STREAM_FIELDS.each { |f| expect(tx).to have_key(f) }
    expect(tx).to include(gateway: orig_gw.name)
    expect(tx).to have_key(:pop)
    expect(tx).to have_key(:node)
    expect(tx).to have_key(:rtcp_rtt_std)
    expect(tx).to have_key(:tx_rtcp_jitter_std)
  end

  it 'stringifies inet host fields so they JSON-encode cleanly' do
    rx = subject[:rx_streams].find { |s| s[:id] == lega_rx1.id }
    expect(rx[:remote_host]).to be_a(String)
    expect(rx[:local_host]).to be_a(String)
  end

  it 'includes streams from all attempts (LegB across reroute)' do
    legb_rx_ids = subject[:rx_streams].select { |s| s[:gateway_id].in?([term_gw1.id, term_gw2.id]) }.map { |s| s[:id] }
    expect(legb_rx_ids).to contain_exactly(legb_rx_attempt1.id, legb_rx_attempt2.id)
  end

  context 'when CDR has no streams at all' do
    let!(:lega_rx1) { nil }
    let!(:lega_tx) { nil }
    let!(:legb_rx_attempt1) { nil }
    let!(:legb_rx_attempt2) { nil }
    let!(:legb_tx_attempt2) { nil }

    it 'returns attempts but empty stream arrays' do
      expect(subject[:attempts]).not_to be_empty
      expect(subject[:rx_streams]).to be_empty
      expect(subject[:tx_streams]).to be_empty
    end
  end
end
