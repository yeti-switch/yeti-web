# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_network_protocol_priorities
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  gateway_network_protocol_priorities_name_key  (name) UNIQUE
#

class Equipment::GatewayNetworkProtocolPriority < ApplicationRecord
  self.table_name = 'class4.gateway_network_protocol_priorities'
end
