# == Schema Information
#
# Table name: class4.gateway_group_balancing_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Equipment::GatewayGroupBalancingMode < Yeti::ActiveRecord
  self.table_name = 'class4.gateway_group_balancing_modes'
end
