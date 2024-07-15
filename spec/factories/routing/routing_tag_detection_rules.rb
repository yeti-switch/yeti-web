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

FactoryBot.define do
  factory :routing_tag_detection_rule, class: 'Routing::RoutingTagDetectionRule' do
    tag_action { Routing::TagAction.clear_action }

    trait :filled do
      association :src_area, factory: :area
      routing_tag_mode_id { Routing::RoutingTagMode.take.id }
    end
  end
end
