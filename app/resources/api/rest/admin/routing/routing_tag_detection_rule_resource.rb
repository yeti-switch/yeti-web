# frozen_string_literal: true

class Api::Rest::Admin::Routing::RoutingTagDetectionRuleResource < ::BaseResource
  model_name 'Routing::RoutingTagDetectionRule'

  attributes :src_prefix, :dst_prefix, :tag_action_value, :routing_tag_ids

  paginator :paged

  has_one :src_area, class_name: 'Area', always_include_linkage_data: true
  has_one :dst_area, class_name: 'Area', always_include_linkage_data: true
  has_one :routing_tag, class_name: 'RoutingTag', always_include_linkage_data: true
  has_one :tag_action, class_name: 'TagAction', always_include_linkage_data: true
  has_one :routing_tag_mode, class_name: 'RoutingTagMode', always_include_linkage_data: true

  ransack_filter :src_prefix, type: :string
  ransack_filter :dst_prefix, type: :string
end
