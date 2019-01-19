# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.radius_accounting_profile_interim_attributes
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

class Equipment::Radius::AccountingProfileInterimAttribute < Equipment::Radius::Attribute
  self.table_name = 'class4.radius_accounting_profile_interim_attributes'
  has_paper_trail class_name: 'AuditLogItem'

  belongs_to :profile, class_name: 'Equipment::Radius::AccountingProfile', foreign_key: :profile_id
end
