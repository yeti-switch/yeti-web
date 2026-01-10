# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.registrations
#
#  id                    :integer(4)       not null, primary key
#  auth_password         :string
#  auth_user             :string
#  contact               :string
#  display_username      :string
#  domain                :string
#  enabled               :boolean          default(TRUE), not null
#  expire                :integer(4)
#  force_expire          :boolean          default(FALSE), not null
#  max_attempts          :integer(2)
#  name                  :string           not null
#  retry_delay           :integer(2)       default(5), not null
#  route_set             :string           default([]), not null, is an Array
#  sip_interface_name    :string
#  username              :string           not null
#  node_id               :integer(4)
#  pop_id                :integer(4)
#  sip_schema_id         :integer(2)       default(1), not null
#  transport_protocol_id :integer(2)       default(1), not null
#
# Indexes
#
#  registrations_name_key  (name) UNIQUE
#
# Foreign Keys
#
#  registrations_node_id_fkey                (node_id => nodes.id)
#  registrations_pop_id_fkey                 (pop_id => pops.id)
#  registrations_transport_protocol_id_fkey  (transport_protocol_id => transport_protocols.id)
#
FactoryBot.define do
  factory :registration, class: 'Equipment::Registration' do
    sequence(:name) { |n| "Equipment Registration #{n}" }
    domain { 'localhost' }
    username { 'user name' }
    contact { 'sip:user@domain' }
    sip_schema_id { 1 }

    trait :filled do
      node
      pop
      transport_protocol { Equipment::TransportProtocol.take }
      sequence(:sip_interface_name) { |n| "interface_#{n}" }
    end
  end
end
