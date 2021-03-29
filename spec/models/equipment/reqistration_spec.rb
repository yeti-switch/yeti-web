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
#  registrations_sip_schema_id_fkey                (sip_schema_id => sip_schemas.id)
#  registrations_transport_protocol_id_fkey        (transport_protocol_id => transport_protocols.id)
#

RSpec.describe Equipment::Registration, type: :model do
  it do
    is_expected.to validate_numericality_of(:retry_delay).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
    is_expected.to validate_numericality_of(:max_attempts).is_less_than_or_equal_to(Yeti::ActiveRecord::PG_MAX_SMALLINT)
  end
end
