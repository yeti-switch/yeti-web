# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_tag_detection_rules
#
#  id                  :integer(2)       not null, primary key
#  dst_prefix          :string           default(""), not null
#  routing_tag_ids     :integer(2)       default([]), not null, is an Array
#  src_prefix          :string           default(""), not null
#  tag_action_value    :integer(2)       default([]), not null, is an Array
#  dst_area_id         :integer(4)
#  routing_tag_mode_id :integer(2)       default(0), not null
#  src_area_id         :integer(4)
#  tag_action_id       :integer(2)
#
# Indexes
#
#  routing_tag_detection_rules_prefix_range_idx  (((src_prefix)::prefix_range), ((dst_prefix)::prefix_range)) USING gist
#
# Foreign Keys
#
#  routing_tag_detection_rules_dst_area_id_fkey          (dst_area_id => areas.id)
#  routing_tag_detection_rules_routing_tag_mode_id_fkey  (routing_tag_mode_id => routing_tag_modes.id)
#  routing_tag_detection_rules_src_area_id_fkey          (src_area_id => areas.id)
#  routing_tag_detection_rules_tag_action_id_fkey        (tag_action_id => tag_actions.id)
#

class Routing::RoutingTagDetectionRule < Yeti::ActiveRecord
  self.table_name = 'class4.routing_tag_detection_rules'

  validates_with TagActionValueValidator
  validates_with RoutingTagIdsValidator

  belongs_to :src_area, class_name: 'Routing::Area', foreign_key: :src_area_id
  belongs_to :dst_area, class_name: 'Routing::Area', foreign_key: :dst_area_id
  belongs_to :tag_action, class_name: 'Routing::TagAction'

  belongs_to :routing_tag_mode, class_name: 'Routing::RoutingTagMode', foreign_key: :routing_tag_mode_id
  array_belongs_to :routing_tags, class_name: 'Routing::RoutingTag', foreign_key: :routing_tag_ids
  array_belongs_to :tag_action_values, class_name: 'Routing::RoutingTag', foreign_key: :tag_action_value

  validates :routing_tag_mode, presence: true

  include RoutingTagIdsScopeable

  def display_name
    id.to_s
  end

  scope :routing_tag_ids_array_contains, ->(*tag_id) { where.contains routing_tag_ids: Array(tag_id) }

  private

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      routing_tag_ids_array_contains
      routing_tag_ids_covers
      tagged
    ]
  end
end
