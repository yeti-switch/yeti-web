# frozen_string_literal: true

# == Schema Information
#
# Table name: registrations
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
#  registrations_sip_schema_id_fkey                (sip_schema_id => sip_schemas.id)
#  registrations_transport_protocol_id_fkey        (transport_protocol_id => transport_protocols.id)
#

class Equipment::Registration < Yeti::ActiveRecord
  belongs_to :transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :transport_protocol_id
  belongs_to :proxy_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :proxy_transport_protocol_id
  belongs_to :pop
  belongs_to :node
  belongs_to :sip_schema, class_name: 'System::SipSchema', foreign_key: :sip_schema_id

  validates :name, uniqueness: { allow_blank: false }
  validates :name, :domain, :username, :retry_delay, :transport_protocol, :proxy_transport_protocol, :sip_schema, presence: true

  # validates_format_of :contact, :with => /\Asip:(.*)\z/
  validates :contact, format: URI::DEFAULT_PARSER.make_regexp(%w[sip])

  validates :retry_delay, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: false, only_integer: true }
  validates :max_attempts, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true }

  include WithPaperTrail

  def display_name
    "#{name} | #{id}"
  end

  include Yeti::ResourceStatus
  include Yeti::RegistrationReloader
end
