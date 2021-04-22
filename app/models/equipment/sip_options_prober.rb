# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.sip_options_probers
#
#  id                          :integer(4)       not null, primary key
#  append_headers              :string
#  auth_password               :string
#  auth_username               :string
#  contact_uri                 :string
#  enabled                     :boolean          default(TRUE), not null
#  from_uri                    :string
#  interval                    :integer(2)       default(60), not null
#  name                        :string           not null
#  proxy                       :string
#  ruri_domain                 :string           not null
#  ruri_username               :string           not null
#  sip_interface_name          :string
#  to_uri                      :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  external_id                 :bigint(8)
#  node_id                     :integer(2)
#  pop_id                      :integer(2)
#  proxy_transport_protocol_id :integer(2)       default(1), not null
#  sip_schema_id               :integer(2)       default(1), not null
#  transport_protocol_id       :integer(2)       default(1), not null
#
# Indexes
#
#  index_class4.sip_options_probers_on_external_id  (external_id) UNIQUE
#  sip_options_probers_name_key                     (name) UNIQUE
#
# Foreign Keys
#
#  sip_options_probers_node_id_fkey                      (node_id => nodes.id)
#  sip_options_probers_pop_id_fkey                       (pop_id => pops.id)
#  sip_options_probers_proxy_transport_protocol_id_fkey  (proxy_transport_protocol_id => transport_protocols.id)
#  sip_options_probers_sip_schema_id_fkey                (sip_schema_id => sip_schemas.id)
#  sip_options_probers_transport_protocol_id_fkey        (transport_protocol_id => transport_protocols.id)
#
class Equipment::SipOptionsProber < Yeti::ActiveRecord
  self.table_name = 'class4.sip_options_probers'

  belongs_to :transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :transport_protocol_id
  belongs_to :proxy_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :proxy_transport_protocol_id
  belongs_to :pop, optional: true
  belongs_to :node, optional: true
  belongs_to :sip_schema, class_name: 'System::SipSchema', foreign_key: :sip_schema_id

  validates :name, uniqueness: { allow_blank: false }
  validates :external_id, uniqueness: { allow_blank: true }
  validates :name, :ruri_domain, :ruri_username, :transport_protocol, :proxy_transport_protocol, :sip_schema, presence: true

  # validates_format_of :contact, :with => /\Asip:(.*)\z/
  #  validates :contact_uri, format: URI::DEFAULT_PARSER.make_regexp(%w[sip])
  #  validates :from_uri, format: URI::DEFAULT_PARSER.make_regexp(%w[sip])
  #  validates :to_uri, format: URI::DEFAULT_PARSER.make_regexp(%w[sip])

  include WithPaperTrail

  def display_name
    "#{name} | #{id}"
  end

  include Yeti::ResourceStatus
  include Yeti::SipOptionsProberReloader
end
