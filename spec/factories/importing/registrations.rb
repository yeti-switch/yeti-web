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
FactoryBot.define do
  factory :importing_registration, class: 'Importing::Registration' do
    o_id { nil }
    name { nil }
    enabled { true }
    pop_name { nil }
    pop_id { nil }
    node_name { nil }
    node_id { nil }
    domain { nil }
    username { nil }
    display_username { nil }
    auth_user { nil }
    proxy { nil }
    contact { nil }
    auth_password { nil }
    expire { nil }
    force_expire { false }
    error_string { nil }
  end
end
