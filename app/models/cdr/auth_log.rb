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
#  auth_error_id         :integer(2)
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
  TRANSPORT_PROTOCOL_SCTP = 4
  TRANSPORT_PROTOCOL_WS = 5
  TRANSPORT_PROTOCOLS = {
    TRANSPORT_PROTOCOL_UDP => 'udp',
    TRANSPORT_PROTOCOL_TCP => 'tcp',
    TRANSPORT_PROTOCOL_TLS => 'tls',
    TRANSPORT_PROTOCOL_SCTP => 'sctp',
    TRANSPORT_PROTOCOL_WS => 'ws'
  }.freeze

  AUTH_ERROR_NO_AUTH_HEADER = 0
  AUTH_ERROR_DIGEST_NO_USERNAME = 2
  AUTH_ERROR_DIGEST_USER_NOT_FOUND = 3
  AUTH_ERROR_IP_AUTH = 4
  AUTH_ERROR_JWT_PARSE_ERROR = 5
  AUTH_ERROR_JWT_VERIFY_ERROR = 6
  AUTH_ERROR_JWT_EXPIRED = 7
  AUTH_ERROR_JWT_DATA_ERROR = 8
  AUTH_ERROR_JWT_AUTH_ERROR = 9
  AUTH_ERROR_GENERIC = 10
  AUTH_ERROR_DIGEST_AUTHORIZATION_PARSE_ERROR = 11
  AUTH_ERROR_DIGEST_WRONG_RESPONSE_LENGTH = 12
  AUTH_ERROR_DIGEST_REALM_MISMATCH = 13
  AUTH_ERROR_DIGEST_USER_MISMATCH = 14
  AUTH_ERROR_DIGEST_WRONG_NONCE = 15
  AUTH_ERROR_DIGEST_EXPIRED_NONCE = 16
  AUTH_ERROR_DIGEST_INVALID_NONCE_COUNT = 17
  AUTH_ERROR_DIGEST_WRONG_RESPONSE = 18
  AUTH_ERROR_DIGEST_NO_AUTH_HEADER = 19

  AUTH_ERRORS = {
    AUTH_ERROR_NO_AUTH_HEADER => 'No Authorization header',
    AUTH_ERROR_DIGEST_NO_USERNAME => 'Missing username attribute',
    AUTH_ERROR_DIGEST_USER_NOT_FOUND => 'User not found',
    AUTH_ERROR_IP_AUTH => 'IP not allowed',
    AUTH_ERROR_JWT_PARSE_ERROR => 'JWT Parse error',
    AUTH_ERROR_JWT_VERIFY_ERROR => 'JWT Verify error',
    AUTH_ERROR_JWT_EXPIRED => 'JWT Expired',
    AUTH_ERROR_JWT_DATA_ERROR => 'JWT Data error',
    AUTH_ERROR_JWT_AUTH_ERROR => 'JWT Not allowed',
    AUTH_ERROR_GENERIC => 'Generic error',
    AUTH_ERROR_DIGEST_AUTHORIZATION_PARSE_ERROR => 'Failed to parse Authorization header',
    AUTH_ERROR_DIGEST_WRONG_RESPONSE_LENGTH => 'Wrong response length',
    AUTH_ERROR_DIGEST_REALM_MISMATCH => 'Realm mismatch',
    AUTH_ERROR_DIGEST_USER_MISMATCH => 'User mismatch',
    AUTH_ERROR_DIGEST_WRONG_NONCE => 'Incorrect nonce',
    AUTH_ERROR_DIGEST_EXPIRED_NONCE => 'Expired nonce',
    AUTH_ERROR_DIGEST_INVALID_NONCE_COUNT => 'Failed to parse nc',
    AUTH_ERROR_DIGEST_WRONG_RESPONSE => 'Response not matched',
    AUTH_ERROR_DIGEST_NO_AUTH_HEADER => 'No Authorization header'
  }.freeze

  AUTH_ERRORS_WITH_CODE = AUTH_ERRORS.map { |k, v| [k, "#{k} #{v}"] }.to_h.freeze

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

  def auth_error_name
    "#{auth_error_id} #{AUTH_ERRORS[auth_error_id]}"
  end
end
