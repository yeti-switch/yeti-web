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
#  request_time          :timestamptz      not null
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
# Indexes
#
#  auth_log_id_idx            (id)
#  auth_log_request_time_idx  (request_time)
#
FactoryBot.define do
  factory :auth_log, class: Cdr::AuthLog do
    request_time                { 1.minute.ago }
    code                        { 200 }
    reason { 'OK' }
    internal_reason { 'Response matched' }
    origination_ip { '1.1.1.1' }
    origination_port { 5060 }
    transport_remote_ip { '2.2.2.2' }
    transport_remote_port { 6050 }
    transport_local_ip { '2.2.2.2' }
    transport_local_port { 6050 }
    username { 'User1' }
    realm { 'Realm1' }
    request_method { 'INVITE' }
    call_id { '2b8a45f5730c1b3459a00b9c322a79da' }
    success { true }

    transport_protocol { Equipment::TransportProtocol.take }
    origination_protocol { Equipment::TransportProtocol.take }

    # association :transport_protocol, factory: :transport_protocol
    # association :origination_protocol, factory: :transport_protocol

    association :gateway, factory: :gateway
    association :pop, factory: :pop
    association :node, factory: :node

    trait :with_id do
      id { Cdr::AuthLog.connection.select_value("SELECT nextval('auth_log.auth_log_id_seq')").to_i }
    end

    before(:create) do |record, _evaluator|
      # Create partition for current record
      Cdr::AuthLog.add_partition_for(record.request_time) if record.request_time
    end
  end
end
