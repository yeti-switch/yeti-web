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
