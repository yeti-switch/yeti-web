class Api::Rest::Admin::Routing::NumberlistItemResource < ::BaseResource
  model_name 'Routing::NumberlistItem'

  attributes :key,
             :src_rewrite_rule, :src_rewrite_result,
             :dst_rewrite_rule, :dst_rewrite_result,
             :tag_action_value

  has_one :action, class_name: 'NumberlistAction'
  has_one :numberlist, class_name: 'Numberlist'
  has_one :tag_action, class_name: 'TagAction'

  filter :key

end
