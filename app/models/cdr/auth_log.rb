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
#  origination_ip        :inet
#  origination_port      :integer(4)
#  pai                   :string
#  ppi                   :string
#  privacy               :string
#  realm                 :string
#  reason                :string
#  request_method        :string
#  request_time          :timestamptz      not null
#  response              :string
#  rpid                  :string
#  rpid_privacy          :string
#  ruri                  :string
#  success               :boolean
#  to_uri                :string
#  transport_local_ip    :inet
#  transport_local_port  :integer(4)
#  transport_remote_ip   :inet
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
# Indexes
#
#  auth_log_id_idx            (id)
#  auth_log_request_time_idx  (request_time)
#

class Cdr::AuthLog < Cdr::Base
  self.table_name = 'auth_log.auth_log'
  self.primary_key = :id

  include Partitionable
  self.pg_partition_name = 'PgPartition::Cdr'
  self.pg_partition_interval_type = PgPartition::INTERVAL_DAY
  self.pg_partition_depth_past = 3
  self.pg_partition_depth_future = 3

  TRANSPORT_PROTOCOL_UDP = 1
  TRANSPORT_PROTOCOL_TCP = 2
  TRANSPORT_PROTOCOL_TLS = 3
  TRANSPORT_PROTOCOLS = {
    TRANSPORT_PROTOCOL_UDP => 'UDP',
    TRANSPORT_PROTOCOL_TCP => 'TCP',
    TRANSPORT_PROTOCOL_TLS => 'TLS'
  }.freeze

  belongs_to :gateway, class_name: 'Gateway', foreign_key: :gateway_id, optional: true
  belongs_to :node, class_name: 'Node', foreign_key: :node_id, optional: true
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id, optional: true

  scope :successful, -> { where success: true }
  scope :failed, -> { where success: false }

  scope :transport_local_ip_covers, lambda { |ip|
    begin
      IPAddr.new(ip)
    rescue StandardError
      return none
    end
    where('transport_local_ip<<=?::inet', ip)
  }

  scope :transport_remote_ip_covers, lambda { |ip|
    begin
      IPAddr.new(ip)
    rescue StandardError
      return none
    end
    where('transport_remote_ip<<=?::inet', ip)
  }

  scope :origination_ip_covers, lambda { |ip|
    begin
      IPAddr.new(ip)
    rescue StandardError
      return none
    end
    where('origination_ip<<=?::inet', ip)
  }

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      origination_ip_covers
      transport_local_ip_covers
      transport_remote_ip_covers
    ]
  end

  def display_name
    id.to_s
  end

  def transport_protocol_name
    TRANSPORT_PROTOCOLS[transport_proto_id]
  end

  def origination_protocol_name
    TRANSPORT_PROTOCOLS[origination_proto_id]
  end
end
