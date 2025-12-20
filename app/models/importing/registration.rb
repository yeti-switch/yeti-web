# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_registrations
#
#  id                            :bigint(8)        not null, primary key
#  auth_password                 :string
#  auth_user                     :string
#  contact                       :string
#  display_username              :string
#  domain                        :string
#  enabled                       :boolean
#  error_string                  :string
#  expire                        :integer(4)
#  force_expire                  :boolean
#  is_changed                    :boolean
#  max_attempts                  :integer(4)
#  name                          :string
#  node_name                     :string
#  pop_name                      :string
#  proxy                         :string
#  proxy_transport_protocol_name :string
#  retry_delay                   :integer(4)
#  sip_schema_name               :string
#  transport_protocol_name       :string
#  username                      :string
#  node_id                       :integer(4)
#  o_id                          :integer(4)
#  pop_id                        :integer(4)
#  proxy_transport_protocol_id   :integer(2)
#  sip_schema_id                 :integer(2)
#  transport_protocol_id         :integer(2)
#

class Importing::Registration < Importing::Base
  self.table_name = 'data_import.import_registrations'
  attr_accessor :file

  belongs_to :pop, class_name: '::Pop', optional: true
  belongs_to :node, class_name: '::Node', optional: true
  belongs_to :transport_protocol, class_name: '::Equipment::TransportProtocol', foreign_key: :transport_protocol_id, optional: true
  belongs_to :proxy_transport_protocol, class_name: '::Equipment::TransportProtocol', foreign_key: :proxy_transport_protocol_id, optional: true
  belongs_to :sip_schema, class_name: 'System::SipSchema', foreign_key: :sip_schema_id, optional: true

  self.import_attributes = %w[name enabled
                              pop_id node_id domain
                              username display_username
                              auth_user auth_password proxy contact
                              expire force_expire retry_delay max_attempts
                              transport_protocol_id proxy_transport_protocol_id sip_schema_id]

  self.strict_unique_attributes = %w[name]

  import_for ::Equipment::Registration
end
