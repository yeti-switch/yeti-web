# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_rel100_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  gateway_rel100_modes_name_key  (name) UNIQUE
#

class Equipment::GatewayRel100Mode < ApplicationRecord
  self.table_name = 'class4.gateway_rel100_modes'
end
