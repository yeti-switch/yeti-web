# frozen_string_literal: true

# == Schema Information
#
# Table name: gateway_groups
#
#  id                :integer(4)       not null, primary key
#  name              :string           not null
#  prefer_same_pop   :boolean          default(TRUE), not null
#  balancing_mode_id :integer(2)       default(1), not null
#  vendor_id         :integer(4)       not null
#
# Indexes
#
#  gateway_groups_name_key       (name) UNIQUE
#  gateway_groups_vendor_id_idx  (vendor_id)
#
# Foreign Keys
#
#  gateway_groups_balancing_mode_id_fkey  (balancing_mode_id => gateway_group_balancing_modes.id)
#  gateway_groups_contractor_id_fkey      (vendor_id => contractors.id)
#
FactoryBot.define do
  factory :gateway_group, class: 'GatewayGroup' do
    sequence(:name) { |n| "gateway_group_#{n}" }
    balancing_mode_id { 2 }
    association :vendor, factory: :contractor, vendor: true
  end
end
