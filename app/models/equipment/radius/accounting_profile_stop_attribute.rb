# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.radius_accounting_profile_stop_attributes
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
#  radius_accounting_profile_stop_attributes_profile_id_fkey  (profile_id => radius_accounting_profiles.id)
#

class Equipment::Radius::AccountingProfileStopAttribute < Equipment::Radius::Attribute
  self.table_name = 'class4.radius_accounting_profile_stop_attributes'
  include WithPaperTrail

  belongs_to :profile, class_name: 'Equipment::Radius::AccountingProfile', foreign_key: :profile_id
end
