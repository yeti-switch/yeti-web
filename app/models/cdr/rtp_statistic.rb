# frozen_string_literal: true

# == Schema Information
#
# Table name: rtp_statistics.streams
#
#  id                      :integer          not null, primary key
#  time_start              :datetime         not null
#  time_end                :datetime
#  pop_id                  :integer          not null
#  node_id                 :integer          not null
#  gateway_id              :integer
#  gateway_external_id     :integer
#  local_tag               :string
#  rtcp_rtt_min            :float
#  rtcp_rtt_max            :float
#  rtcp_rtt_mean           :float
#  rtcp_rtt_std            :float
#  rx_rtcp_rr_count        :integer
#  rx_rtcp_sr_count        :integer
#  tx_rtcp_rr_count        :integer
#  tx_rtcp_sr_count        :integer
#  local_host              :string
#  local_port              :integer
#  remote_host             :string
#  remote_port             :integer
#  rx_ssrc                 :integer
#  rx_packets              :integer
#  rx_bytes                :integer
#  rx_total_lost           :integer
#  rx_payloads_transcoded  :string
#  rx_payloads_relayed     :string
#  rx_decode_errors        :integer
#  rx_out_of_buffer_errors :integer
#  rx_rtp_parse_errors     :integer
#  rx_packet_delta_min     :float
#  rx_packet_delta_max     :float
#  rx_packet_delta_mean    :float
#  rx_packet_delta_std     :float
#  rx_packet_jitter_min    :float
#  rx_packet_jitter_max    :float
#  rx_packet_jitter_mean   :float
#  rx_packet_jitter_std    :float
#  rx_rtcp_jitter_min      :float
#  rx_rtcp_jitter_max      :float
#  rx_rtcp_jitter_mean     :float
#  rx_rtcp_jitter_std      :float
#  tx_ssrc                 :integer
#  tx_packets              :integer
#  tx_bytes                :integer
#  tx_total_lost           :integer
#  tx_payloads_transcoded  :string
#  tx_payloads_relayed     :string
#  tx_rtcp_jitter_min      :float
#  tx_rtcp_jitter_max      :float
#  tx_rtcp_jitter_mean     :float
#  tx_rtcp_jitter_std      :float
#

class Cdr::RtpStatistic < Cdr::Base
  self.table_name = 'rtp_statistics.streams'
  self.primary_key = :id

  belongs_to :gateway, class_name: 'Gateway', foreign_key: :gateway_id
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id
  belongs_to :node, class_name: 'Node', foreign_key: :node_id

  def display_name
    id.to_s
  end
end
