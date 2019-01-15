# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_gateway_groups
#
#  id              :integer          not null, primary key
#  o_id            :integer
#  name            :string
#  vendor_name     :string
#  vendor_id       :integer
#  prefer_same_pop :boolean
#  error_string    :string
#

class Importing::GatewayGroup < Importing::Base
  self.table_name = 'data_import.import_gateway_groups'
  attr_accessor :file

  belongs_to :vendor, -> { where vendor: true }, class_name: '::Contractor', foreign_key: :vendor_id

  self.import_attributes = %w[name vendor_id prefer_same_pop]

  self.import_class = ::GatewayGroup
end
