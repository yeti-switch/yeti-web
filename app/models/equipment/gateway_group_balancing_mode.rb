# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_group_balancing_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  gateway_group_balancing_modes_name_key  (name) UNIQUE
#

class Equipment::GatewayGroupBalancingMode < Yeti::ActiveRecord
  self.table_name = 'class4.gateway_group_balancing_modes'
end
