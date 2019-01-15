# frozen_string_literal: true

# == Schema Information
#
# Table name: import_routing_groups
#
#  id                       :integer          not null, primary key
#  o_id                     :integer
#  name                     :string
#  sorting_name             :string
#  sorting_id               :integer
#  more_specific_per_vendor :boolean
#  rate_delta_max           :decimal(, )      default(0.0), not null
#  error_string             :string
#

class Importing::RoutingGroup < Importing::Base
  self.table_name = 'import_routing_groups'

  belongs_to :sorting, class_name: '::Sorting'

  self.import_attributes = ['name']
  self.import_class = ::RoutingGroup
end
