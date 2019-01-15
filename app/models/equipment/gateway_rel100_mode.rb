# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_rel100_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Equipment::GatewayRel100Mode < Yeti::ActiveRecord
  self.table_name = 'class4.gateway_rel100_modes'
end
