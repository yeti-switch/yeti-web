# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.radius_auth_profile_attributes
#
#  id              :integer(2)       not null, primary key
#  format          :string           not null
#  is_vsa          :boolean          default(FALSE), not null
#  name            :string           not null
#  value           :string           not null
#  vsa_vendor_type :integer(2)
#  profile_id      :integer(2)       not null
#  type_id         :integer(2)       not null
#  vsa_vendor_id   :integer(4)
#
# Foreign Keys
#
#  radius_auth_profile_attributes_profile_id_fkey  (profile_id => radius_auth_profiles.id)
#

class Equipment::Radius::AuthProfileAttribute < Equipment::Radius::Attribute
  self.table_name = 'class4.radius_auth_profile_attributes'
  has_paper_trail class_name: 'AuditLogItem'

  belongs_to :profile, class_name: 'Equipment::Radius::AuthProfile', foreign_key: :profile_id

  def self.variables
    fetch_sp("select varname from #{ROUTING_SCHEMA}.load_interface_out() where forradius").to_a
  end
end
