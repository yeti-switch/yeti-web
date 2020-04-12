# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_registrations
#
#  id                            :integer          not null, primary key
#  o_id                          :integer
#  name                          :string
#  enabled                       :boolean
#  pop_name                      :string
#  pop_id                        :integer
#  node_name                     :string
#  node_id                       :integer
#  domain                        :string
#  username                      :string
#  display_username              :string
#  auth_user                     :string
#  proxy                         :string
#  contact                       :string
#  auth_password                 :string
#  expire                        :integer
#  force_expire                  :boolean
#  error_string                  :string
#  retry_delay                   :integer
#  max_attempts                  :integer
#  transport_protocol_id         :integer
#  proxy_transport_protocol_id   :integer
#  transport_protocol_name       :string
#  proxy_transport_protocol_name :string
#  is_changed                    :boolean
#

class Importing::Registration < Importing::Base
  self.table_name = 'data_import.import_registrations'
  attr_accessor :file

  belongs_to :pop, class_name: '::Pop'
  belongs_to :node, class_name: '::Node'
  belongs_to :transport_protocol, class_name: '::Equipment::TransportProtocol', foreign_key: :transport_protocol_id
  belongs_to :proxy_transport_protocol, class_name: '::Equipment::TransportProtocol', foreign_key: :proxy_transport_protocol_id

  self.import_attributes = %w[name enabled
                              pop_id node_id domain
                              username display_username
                              auth_user auth_password proxy contact
                              expire force_expire retry_delay max_attempts
                              transport_protocol_id proxy_transport_protocol_id]

  import_for ::Equipment::Registration
end
