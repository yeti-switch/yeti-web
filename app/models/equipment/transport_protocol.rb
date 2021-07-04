# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.transport_protocols
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  transport_protocols_name_key  (name) UNIQUE
#

class Equipment::TransportProtocol < ApplicationRecord
  self.table_name = 'class4.transport_protocols'

  def display_name
    name
  end
end
