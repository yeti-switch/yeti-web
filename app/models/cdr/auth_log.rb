# frozen_string_literal: true

# == Schema Information
#
# Table name: auth_log.auth_log
#
#  id                    :bigint(8)        not null, primary key
#  code                  :integer(2)
#  diversion             :string
#  from_uri              :string
#  internal_reason       :string
#  nonce                 :string
#  origination_ip        :string
#  origination_port      :integer(4)
#  pai                   :string
#  ppi                   :string
#  privacy               :string
#  realm                 :string
#  reason                :string
#  request_method        :string
#  request_time          :datetime         not null
#  response              :string
#  rpid                  :string
#  rpid_privacy          :string
#  ruri                  :string
#  success               :boolean
#  to_uri                :string
#  transport_local_ip    :string
#  transport_local_port  :integer(4)
#  transport_remote_ip   :string
#  transport_remote_port :integer(4)
#  username              :string
#  x_yeti_auth           :string
#  call_id               :string
#  gateway_id            :integer(4)
#  node_id               :integer(2)
#  origination_proto_id  :integer(2)
#  pop_id                :integer(2)
#  transport_proto_id    :integer(2)
#

class Cdr::AuthLog < Cdr::Base
  self.table_name = 'auth_log.auth_log'
  self.primary_key = :id

  include Partitionable
  self.pg_partition_name = 'PgPartition::Cdr'
  self.pg_partition_interval_type = PgPartition::INTERVAL_DAY
  self.pg_partition_depth_past = 3
  self.pg_partition_depth_future = 3

  belongs_to :gateway, class_name: 'Gateway', foreign_key: :gateway_id, optional: true
  belongs_to :node, class_name: 'Node', foreign_key: :node_id, optional: true
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id, optional: true
  belongs_to :origination_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :origination_proto_id, optional: true
  belongs_to :transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :transport_proto_id, optional: true

  scope :successful, -> { where success: true }
  scope :failed, -> { where success: false }

  def display_name
    id.to_s
  end
end
