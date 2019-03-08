# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_gateway_groups
#
#  id                  :integer          not null, primary key
#  o_id                :integer
#  name                :string
#  vendor_name         :string
#  vendor_id           :integer
#  error_string        :string
#  balancing_mode_id   :integer
#  balancing_mode_name :string
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

  self.import_class = ::GatewayGroup
end
