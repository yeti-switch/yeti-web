# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.radius_accounting_profile_stop_attributes
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

FactoryBot.define do
  factory :accounting_profile_stop_attribute, class: Equipment::Radius::AccountingProfileStopAttribute do
    association :profile, factory: :accounting_profile
    type_id { 1 }
    sequence(:name) { |n| "accounting_profile_stop_#{n}" }
    value { 'value' }
    format { 'string' }
    is_vsa { false }
  end
end
