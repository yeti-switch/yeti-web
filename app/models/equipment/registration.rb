# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.registrations
#
#  id                          :integer(4)       not null, primary key
#  auth_password               :string
#  auth_user                   :string
#  contact                     :string
#  display_username            :string
#  domain                      :string
#  enabled                     :boolean          default(TRUE), not null
#  expire                      :integer(4)
#  force_expire                :boolean          default(FALSE), not null
#  max_attempts                :integer(2)
#  name                        :string           not null
#  proxy                       :string
#  retry_delay                 :integer(2)       default(5), not null
#  sip_interface_name          :string
#  username                    :string           not null
#  node_id                     :integer(4)
#  pop_id                      :integer(4)
#  proxy_transport_protocol_id :integer(2)       default(1), not null
#  sip_schema_id               :integer(2)       default(1), not null
#  transport_protocol_id       :integer(2)       default(1), not null
#
# Indexes
#
#  registrations_name_key  (name) UNIQUE
#
# Foreign Keys
#
#  registrations_node_id_fkey                      (node_id => nodes.id)
#  registrations_pop_id_fkey                       (pop_id => pops.id)
#  registrations_proxy_transport_protocol_id_fkey  (proxy_transport_protocol_id => transport_protocols.id)
#  registrations_transport_protocol_id_fkey        (transport_protocol_id => transport_protocols.id)
#

class Equipment::Registration < ApplicationRecord
  self.table_name = 'class4.registrations'

  SIP_SCHEMA_SIP = 1
  SIP_SCHEMA_SIPS = 2
  SIP_SCHEMAS = {
    SIP_SCHEMA_SIP => 'sip',
    SIP_SCHEMA_SIPS => 'sips'
  }.freeze

  belongs_to :transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :transport_protocol_id
  belongs_to :proxy_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :proxy_transport_protocol_id
  belongs_to :pop, optional: true
  belongs_to :node, optional: true

  validates :name, uniqueness: { allow_blank: false }
  validates :name, :domain, :username, :retry_delay, :transport_protocol, :proxy_transport_protocol, :sip_schema_id, presence: true

  # validates_format_of :contact, :with => /\Asip:(.*)\z/
  validates :contact, format: URI::DEFAULT_PARSER.make_regexp(%w[sip])

  validates :retry_delay, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: false, only_integer: true }
  validates :max_attempts, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true }
  validates :sip_schema_id, inclusion: { in: SIP_SCHEMAS.keys }, allow_nil: false

  include WithPaperTrail

  def display_name
    "#{name} | #{id}"
  end

  def sip_schema_name
    SIP_SCHEMAS[sip_schema_id]
  end

  include Yeti::ResourceStatus
  include Yeti::StateUpdater
  self.state_names = ['registrations']
end
