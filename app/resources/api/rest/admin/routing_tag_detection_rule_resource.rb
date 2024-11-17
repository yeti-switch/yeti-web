# frozen_string_literal: true

class Api::Rest::Admin::RoutingTagDetectionRuleResource < ::BaseResource
  model_name 'Routing::RoutingTagDetectionRule'

  attributes :src_prefix, :dst_prefix, :tag_action_value, :routing_tag_ids

  paginator :paged

  has_one :src_area, class_name: 'Area'
  has_one :dst_area, class_name: 'Area'
  has_one :routing_tag, class_name: 'RoutingTag'
  has_one :tag_action, class_name: 'TagAction'
  has_one :routing_tag_mode, class_name: 'RoutingTagMode'

  ransack_filter :src_prefix, type: :string
  ransack_filter :dst_prefix, type: :string
end
