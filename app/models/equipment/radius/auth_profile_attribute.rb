# == Schema Information
#
# Table name: class4.radius_auth_profile_attributes
#
#  id              :integer          not null, primary key
#  profile_id      :integer          not null
#  type_id         :integer          not null
#  name            :string           not null
#  value           :string           not null
#  format          :string           not null
#  is_vsa          :boolean          default(FALSE), not null
#  vsa_vendor_id   :integer
#  vsa_vendor_type :integer
#

class Equipment::Radius::AuthProfileAttribute < Equipment::Radius::Attribute
  self.table_name='class4.radius_auth_profile_attributes'
  has_paper_trail class_name: 'AuditLogItem'

  belongs_to :profile, class_name: 'Equipment::Radius::AuthProfile', foreign_key: :profile_id

  def self.variables
    fetch_sp("select varname from #{ROUTING_SCHEMA}.load_interface_out() where forradius").to_a
  end

end
