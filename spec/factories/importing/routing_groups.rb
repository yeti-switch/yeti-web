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
FactoryBot.define do
  factory :importing_routing_group, class: Importing::RoutingGroup do
    o_id { nil }
    name { nil }
    error_string { nil }
  end
end
