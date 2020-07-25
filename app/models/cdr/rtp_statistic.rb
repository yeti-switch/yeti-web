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

class Cdr::RtpStatistic < Cdr::Base
  self.table_name = 'rtp_statistics.streams'
  self.primary_key = :id

  include Partitionable
  self.pg_partition_name = 'PgPartition::Cdr'
  self.pg_partition_interval_type = PgPartition::INTERVAL_DAY
  self.pg_partition_depth_past = 3
  self.pg_partition_depth_future = 3

  belongs_to :gateway, class_name: 'Gateway', foreign_key: :gateway_id
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id
  belongs_to :node, class_name: 'Node', foreign_key: :node_id

  scope :no_rx, -> { where rx_packets: 0 }
  scope :no_tx, -> { where tx_packets: 0 }

  def display_name
    id.to_s
  end
end
