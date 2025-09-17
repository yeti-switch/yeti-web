# frozen_string_literal: true

# == Schema Information
#
# Table name: gateway_groups
#
#  id                     :integer(4)       not null, primary key
#  max_rerouting_attempts :integer(2)       default(10), not null
#  name                   :string           not null
#  prefer_same_pop        :boolean          default(TRUE), not null
#  balancing_mode_id      :integer(2)       default(1), not null
#  vendor_id              :integer(4)       not null
#
# Indexes
#
#  gateway_groups_name_key       (name) UNIQUE
#  gateway_groups_vendor_id_idx  (vendor_id)
#
# Foreign Keys
#
#  gateway_groups_contractor_id_fkey  (vendor_id => contractors.id)
#
FactoryBot.define do
  factory :gateway_group, class: 'GatewayGroup' do
    sequence(:name) { |n| "gateway_group_#{n}" }
    balancing_mode_id { 2 }
    max_rerouting_attempts { 5 }
    association :vendor, factory: :contractor, vendor: true
  end
end
