# frozen_string_literal: true

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
