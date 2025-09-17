# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_gateway_groups
#
#  id                     :bigint(8)        not null, primary key
#  balancing_mode_name    :string
#  error_string           :string
#  is_changed             :boolean
#  max_rerouting_attempts :integer(2)
#  name                   :string
#  prefer_same_pop        :boolean
#  vendor_name            :string
#  balancing_mode_id      :integer(2)
#  o_id                   :integer(4)
#  vendor_id              :integer(4)
#
FactoryBot.define do
  factory :importing_gateway_group, class: 'Importing::GatewayGroup' do
    o_id { nil }
    name { nil }
    vendor_name { nil }
    vendor_id { nil }
    balancing_mode_id { 1 }
    error_string { nil }
  end
end
