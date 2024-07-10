# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_routing_tag_detection_rules
#
#  id                     :bigint(8)        not null, primary key
#  dst_area_name          :string
#  dst_prefix             :string
#  error_string           :string
#  is_changed             :boolean
#  routing_tag_ids        :integer(2)       default([]), not null, is an Array
#  routing_tag_names      :string
#  src_area_name          :string
#  src_prefix             :string
#  tag_action_name        :string
#  tag_action_value       :integer(2)       default([]), not null, is an Array
#  tag_action_value_names :string
#  dst_area_id            :integer(4)
#  o_id                   :bigint(8)
#  src_area_id            :integer(4)
#  tag_action_id          :integer(2)
#
# Indexes
#
#  index_import_routing_tag_detection_rules_on_dst_area_id    (dst_area_id)
#  index_import_routing_tag_detection_rules_on_src_area_id    (src_area_id)
#  index_import_routing_tag_detection_rules_on_tag_action_id  (tag_action_id)
#
# Foreign Keys
#
#  fk_rails_c247bd5783  (tag_action_id => tag_actions.id)
#  fk_rails_c8cbef7aaf  (dst_area_id => areas.id)
#  fk_rails_db4b62868c  (src_area_id => areas.id)
#
FactoryBot.define do
  factory :importing_routing_tag_detection_rule, class: Importing::RoutingTagDetectionRule do
    transient do
      _routing_tags { create_list(:routing_tag, 2) }
      _tag_action { Routing::TagAction.take }
    end

    o_id { nil }
    error_string { nil }
    tag_action_id { _tag_action.id }
    tag_action_name { _tag_action.name }
    src_prefix { 'src-1, src-2' }
    dst_prefix { 'dst-1, dst-2' }
    dst_area_name { 'any' }
    src_area_name { 'any' }
    routing_tag_ids { _routing_tags.map(&:name).join(', ') }
    routing_tag_names { _routing_tags.map(&:id) }
  end
end
