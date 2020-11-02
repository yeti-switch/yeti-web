# frozen_string_literal: true

# == Schema Information
#
# Table name: import_routing_groups
#
#  id           :bigint(8)        not null, primary key
#  error_string :string
#  is_changed   :boolean
#  name         :string
#  o_id         :integer(4)
#

class Importing::RoutingGroup < Importing::Base
  self.table_name = 'import_routing_groups'

  self.import_attributes = %w[name]
  import_for ::RoutingGroup
end
