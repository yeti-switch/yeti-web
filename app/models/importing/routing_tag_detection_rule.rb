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
class Importing::RoutingTagDetectionRule < Importing::Base
  self.table_name = 'data_import.import_routing_tag_detection_rules'

  belongs_to :src_area, class_name: 'Routing::Area', foreign_key: :src_area_id, optional: true
  belongs_to :dst_area, class_name: 'Routing::Area', foreign_key: :dst_area_id, optional: true
  belongs_to :tag_action, class_name: 'Routing::TagAction', optional: true

  self.import_attributes = %w[
    routing_tag_ids
    src_area_id
    dst_area_id
    src_prefix
    dst_prefix
    tag_action_id
    tag_action_value
  ]

  def routing_tag_mode_name
    routing_tag_mode_id.nil? ? 'nil' : Routing::RoutingTagMode::MODES[routing_tag_mode_id]
  end

  def self.after_import_hook
    resolve_array_of_tags('routing_tag_ids', 'routing_tag_names')
    resolve_null_tag('routing_tag_ids', 'routing_tag_names')
    resolve_array_of_tags('tag_action_value', 'tag_action_value_names')
    super
  end

  import_for ::Routing::RoutingTagDetectionRule
end
