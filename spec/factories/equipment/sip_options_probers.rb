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
#  sip_options_probers_name_key  (name) UNIQUE
#
# Foreign Keys
#
#  sip_options_probers_node_id_fkey                      (node_id => nodes.id)
#  sip_options_probers_pop_id_fkey                       (pop_id => pops.id)
#  sip_options_probers_proxy_transport_protocol_id_fkey  (proxy_transport_protocol_id => transport_protocols.id)
#  sip_options_probers_sip_schema_id_fkey                (sip_schema_id => sip_schemas.id)
#  sip_options_probers_transport_protocol_id_fkey        (transport_protocol_id => transport_protocols.id)
#
FactoryBot.define do
  factory :sip_options_prober, class: Equipment::SipOptionsProber do
    sequence(:name) { |n| "SIP Options Prober #{n}" }
    sequence(:ruri_domain) { |n| "#{n}.sip.com" }
    sequence(:ruri_username) { |n| "username_#{n}" }
    pop_id { nil }
    node_id { nil }
  end
end
