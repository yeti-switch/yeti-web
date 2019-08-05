# == Schema Information
#
# Table name: class4.gateway_nat_handling_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Equipment::GatewayNatHandlingMode < Yeti::ActiveRecord
  self.table_name = 'class4.gateway_nat_handling_modes'
end
