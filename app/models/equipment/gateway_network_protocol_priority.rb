# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_network_protocol_priorities
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Equipment::GatewayNetworkProtocolPriority < Yeti::ActiveRecord
  self.table_name = 'class4.gateway_network_protocol_priorities'
end
