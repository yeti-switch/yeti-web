# frozen_string_literal: true

# == Schema Information
#
# Table name: rtp_statistics.tx_streams
#
#  id                      :bigint(8)        not null, primary key
#  local_host              :inet
#  local_port              :integer(4)
#  local_tag               :string           not null
#  rtcp_rtt_max            :float
#  rtcp_rtt_mean           :float
#  rtcp_rtt_min            :float
#  rtcp_rtt_std            :float
#  rx_dropped_packets      :integer(4)
#  rx_out_of_buffer_errors :integer(4)
#  rx_rtp_parse_errors     :integer(4)
#  time_end                :datetime
#  time_start              :datetime         not null
#  tx_bytes                :integer(4)
#  tx_packets              :integer(4)
#  tx_payloads_relayed     :string           is an Array
#  tx_payloads_transcoded  :string           is an Array
#  tx_rtcp_jitter_max      :float
#  tx_rtcp_jitter_mean     :float
#  tx_rtcp_jitter_min      :float
#  tx_rtcp_jitter_std      :float
#  tx_ssrc                 :integer(4)
#  tx_total_lost           :integer(4)
#  gateway_external_id     :bigint(8)
#  gateway_id              :bigint(8)
#  node_id                 :integer(4)
#  pop_id                  :integer(4)
#
class RtpStatistics::TxStream < Cdr::Base
  self.table_name = 'rtp_statistics.tx_streams'
  self.primary_key = :id

  include Partitionable
  self.pg_partition_name = 'PgPartition::Cdr'
  self.pg_partition_interval_type = PgPartition::INTERVAL_DAY
  self.pg_partition_depth_past = 3
  self.pg_partition_depth_future = 3

  belongs_to :gateway, class_name: 'Gateway', foreign_key: :gateway_id, optional: true
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id
  belongs_to :node, class_name: 'Node', foreign_key: :node_id

  scope :no_tx, -> { where tx_packets: 0 }
  scope :tx_ssrc_hex, ->(value) { ransack(tx_ssrc_equals: value.hex).result }

  def display_name
    id.to_s
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[tx_ssrc_hex]
  end
end
