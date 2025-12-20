# frozen_string_literal: true

# == Schema Information
#
# Table name: import_disconnect_policies
#
#  id           :bigint(8)        not null, primary key
#  error_string :string
#  is_changed   :boolean
#  name         :string
#  o_id         :integer(4)
#

class Importing::DisconnectPolicy < Importing::Base
  self.table_name = 'import_disconnect_policies'

  self.import_attributes = %w[name]
  self.strict_unique_attributes = %w[name]

  import_for ::DisconnectPolicy
end
