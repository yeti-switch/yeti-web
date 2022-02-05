# frozen_string_literal: true

# == Schema Information
#
# Table name: rtp_statistics.streams
#
#  id                      :bigint(8)        not null, primary key
#  local_host              :string
#  local_port              :integer(4)
#  local_tag               :string
#  remote_host             :string
#  remote_port             :integer(4)
#  rtcp_rtt_max            :float
#  rtcp_rtt_mean           :float
#  rtcp_rtt_min            :float
#  rtcp_rtt_std            :float
#  rx_bytes                :bigint(8)
#  rx_decode_errors        :bigint(8)
#  rx_out_of_buffer_errors :bigint(8)
#  rx_packet_delta_max     :float
#  rx_packet_delta_mean    :float
#  rx_packet_delta_min     :float
#  rx_packet_delta_std     :float
#  rx_packet_jitter_max    :float
#  rx_packet_jitter_mean   :float
#  rx_packet_jitter_min    :float
#  rx_packet_jitter_std    :float
#  rx_packets              :bigint(8)
#  rx_payloads_relayed     :string
#  rx_payloads_transcoded  :string
#  rx_rtcp_jitter_max      :float
#  rx_rtcp_jitter_mean     :float
#  rx_rtcp_jitter_min      :float
#  rx_rtcp_jitter_std      :float
#  rx_rtcp_rr_count        :bigint(8)
#  rx_rtcp_sr_count        :bigint(8)
#  rx_rtp_parse_errors     :bigint(8)
#  rx_ssrc                 :bigint(8)
#  rx_total_lost           :bigint(8)
#  time_end                :datetime
#  time_start              :datetime         not null
#  tx_bytes                :bigint(8)
#  tx_packets              :bigint(8)
#  tx_payloads_relayed     :string
#  tx_payloads_transcoded  :string
#  tx_rtcp_jitter_max      :float
#  tx_rtcp_jitter_mean     :float
#  tx_rtcp_jitter_min      :float
#  tx_rtcp_jitter_std      :float
#  tx_rtcp_rr_count        :bigint(8)
#  tx_rtcp_sr_count        :bigint(8)
#  tx_ssrc                 :bigint(8)
#  tx_total_lost           :bigint(8)
#  gateway_external_id     :bigint(8)
#  gateway_id              :bigint(8)
#  node_id                 :integer(4)       not null
#  pop_id                  :integer(4)       not null
#
# Indexes
#
#  streams_id_idx         (id)
#  streams_local_tag_idx  (local_tag)
#
RSpec.describe Cdr::RtpStatistic do
  describe 'scope' do
    subject { described_class.public_send(scope_name, scope_value) }

    let(:record_attrs) { {} }
    let!(:record) { FactoryBot.create(:rtp_statistic, record_attrs) }
    let!(:records) { FactoryBot.create_list(:rtp_statistic, 2) }
    let(:scope_name) { :all }
    let(:scope_value) { '' }

    describe '.rx_ssrc_hex' do
      let(:scope_name) { :rx_ssrc_hex }
      let(:record_attrs) { { rx_ssrc: '123' } }

      context 'when value is empty string' do
        let(:scope_value) { '' }

        it 'should NOT include record in scope' do
          expect(subject).not_to include(record)
        end
      end

      context 'when value is string' do
        let(:scope_value) { 'string' }

        it 'should NOT include record in scope' do
          expect(subject).not_to include(record)
        end
      end

      context 'when value is Hexadecimal' do
        let(:scope_value) { '007B' }
        let(:record_attrs) { { rx_ssrc: '123' } }

        it 'should include record in scope' do
          expect(subject).to include(record)
        end
      end

      context 'when value is Decimal' do
        let(:scope_value) { '123' }
        let(:record_attrs) { { rx_ssrc: '123' } }

        it 'should NOT include record in scope' do
          expect(subject).not_to include(record)
        end
      end
    end

    describe '.tx_ssrc_hex' do
      let(:scope_name) { :tx_ssrc_hex }
      let(:record_attrs) { { tx_ssrc: '123' } }

      context 'when value is empty string' do
        let(:scope_value) { '' }

        it 'should NOT include record in scope' do
          expect(subject).not_to include(record)
        end
      end

      context 'when value is string' do
        let(:scope_value) { 'string' }

        it 'should NOT include record in scope' do
          expect(subject).not_to include(record)
        end
      end

      context 'when value is Hexadecimal' do
        let(:scope_value) { '007B' }

        it 'should include record in scope' do
          expect(subject).to include(record)
        end
      end

      context 'when value is Decimal' do
        let(:scope_value) { '123' }
        let(:record_attrs) { { tx_ssrc: '123' } }

        it 'should NOT include record in scope' do
          expect(subject).not_to include(record)
        end
      end
    end
  end
end
