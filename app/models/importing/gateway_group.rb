# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_gateway_groups
#
#  id                  :bigint(8)        not null, primary key
#  balancing_mode_name :string
#  error_string        :string
#  is_changed          :boolean
#  name                :string
#  prefer_same_pop     :boolean
#  vendor_name         :string
#  balancing_mode_id   :integer(2)
#  o_id                :integer(4)
#  vendor_id           :integer(4)
#

class Importing::GatewayGroup < Importing::Base
  self.table_name = 'data_import.import_gateway_groups'
  attr_accessor :file

  belongs_to :vendor, -> { where vendor: true }, class_name: '::Contractor', foreign_key: :vendor_id
  belongs_to :balancing_mode, class_name: 'Equipment::GatewayGroupBalancingMode', foreign_key: :balancing_mode_id

  self.import_attributes = %w[
    name
    vendor_id
    balancing_mode_id
  ]

  import_for ::GatewayGroup
end
