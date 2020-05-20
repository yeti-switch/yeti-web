# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_tag_detection_rules
#
#  id                  :integer          not null, primary key
#  dst_area_id         :integer
#  src_area_id         :integer
#  tag_action_id       :integer
#  tag_action_value    :integer          default([]), not null, is an Array
#  routing_tag_ids     :integer          default([]), not null, is an Array
#  routing_tag_mode_id :integer          default(0), not null
#  src_prefix          :string           default(""), not null
#  dst_prefix          :string           default(""), not null
#

FactoryBot.define do
  factory :routing_tag_detection_rule, class: Routing::RoutingTagDetectionRule do
    tag_action { Routing::TagAction.clear_action }

    trait :filled do
      association :src_area, factory: :area
      routing_tag_mode_id { Routing::RoutingTagMode.take.id }
    end
  end
end
