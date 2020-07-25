# frozen_string_literal: true

# == Schema Information
#
# Table name: import_routing_groups
#
#  id                       :bigint(8)        not null, primary key
#  error_string             :string
#  is_changed               :boolean
#  more_specific_per_vendor :boolean
#  name                     :string
#  rate_delta_max           :decimal(, )      default(0.0), not null
#  sorting_name             :string
#  o_id                     :integer(4)
#  sorting_id               :integer(4)
#

class Importing::RoutingGroup < Importing::Base
  self.table_name = 'import_routing_groups'

  belongs_to :sorting, class_name: '::Sorting'

  self.import_attributes = ['name']
  import_for ::RoutingGroup
end
