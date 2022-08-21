# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_diversion_send_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  gateway_diversion_send_modes_name_key  (name) UNIQUE
#
class Equipment::GatewayDiversionSendMode < ApplicationRecord
  self.table_name = 'class4.gateway_diversion_send_modes'

  validates :name, presence: true, uniqueness: true
end
