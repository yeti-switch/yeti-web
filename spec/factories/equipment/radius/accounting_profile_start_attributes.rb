# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.radius_accounting_profile_start_attributes
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
#  radius_accounting_profile_start_attributes_profile_id_fkey  (profile_id => radius_accounting_profiles.id)
#

FactoryBot.define do
  factory :accounting_profile_start_attribute, class: Equipment::Radius::AccountingProfileStartAttribute do
    association :profile, factory: :accounting_profile
    type_id { 1 }
    sequence(:name) { |n| "accounting_profile_start_#{n}" }
    value { 'value' }
    format { 'string' }
    is_vsa { false }
  end
end
