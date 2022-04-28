# frozen_string_literal: true

# == Schema Information
#
# Table name: rtp_statistics.rx_streams
#
#  id                     :bigint(8)        not null, primary key
#  local_host             :inet
#  local_port             :integer(4)
#  local_tag              :string
#  remote_host            :inet
#  remote_port            :integer(4)
#  rx_bytes               :integer(4)
#  rx_decode_errors       :integer(4)
#  rx_packet_delta_max    :float
#  rx_packet_delta_mean   :float
#  rx_packet_delta_min    :float
#  rx_packet_delta_std    :float
#  rx_packet_jitter_max   :float
#  rx_packet_jitter_mean  :float
#  rx_packet_jitter_min   :float
#  rx_packet_jitter_std   :float
#  rx_packets             :integer(4)
#  rx_payloads_relayed    :string           is an Array
#  rx_payloads_transcoded :string           is an Array
#  rx_rtcp_jitter_max     :float
#  rx_rtcp_jitter_mean    :float
#  rx_rtcp_jitter_min     :float
#  rx_rtcp_jitter_std     :float
#  rx_ssrc                :integer(4)
#  rx_total_lost          :integer(4)
#  time_end               :datetime
#  time_start             :datetime         not null
#  gateway_external_id    :bigint(8)
#  gateway_id             :bigint(8)
#  node_id                :integer(4)
#  pop_id                 :integer(4)
#  tx_stream_id           :bigint(8)
#
class RtpStatistics::RxStream < Cdr::Base
  self.table_name = 'rtp_statistics.rx_streams'
  self.primary_key = :id

  include Partitionable
  self.pg_partition_name = 'PgPartition::Cdr'
  self.pg_partition_interval_type = PgPartition::INTERVAL_DAY
  self.pg_partition_depth_past = 3
  self.pg_partition_depth_future = 3

  belongs_to :gateway, class_name: 'Gateway', foreign_key: :gateway_id, optional: true
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id
  belongs_to :node, class_name: 'Node', foreign_key: :node_id

  scope :no_rx, -> { where rx_packets: 0 }
  scope :rx_ssrc_hex, ->(value) { ransack(rx_ssrc_equals: value.hex).result }

  def display_name
    id.to_s
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[rx_ssrc_hex]
  end
end
