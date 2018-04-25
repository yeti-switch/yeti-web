class Api::Rest::Admin::Routing::RoutingTagDetectionRuleResource < ::BaseResource
  model_name 'Routing::RoutingTagDetectionRule'

  attributes :tag_action_value, :routing_tag_ids

  has_one :src_area, class_name: 'Area'
  has_one :dst_area, class_name: 'Area'
  has_one :routing_tag, class_name: 'RoutingTag'
  has_one :tag_action, class_name: 'TagAction'
  has_one :routing_tag_mode, class_name: 'RoutingTagMode'

end
