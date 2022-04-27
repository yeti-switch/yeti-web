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
