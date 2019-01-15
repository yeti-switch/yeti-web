# frozen_string_literal: true

# == Schema Information
#
# Table name: import_disconnect_policies
#
#  id           :integer          not null, primary key
#  o_id         :integer
#  name         :string
#  error_string :string
#

class Importing::DisconnectPolicy < Importing::Base
  self.table_name = 'import_disconnect_policies'

  self.import_attributes = ['name']
  self.import_class = ::DisconnectPolicy
end
