class Api::Rest::Admin::Routing::NumberlistResource < ::BaseResource
  model_name 'Routing::Numberlist'

  attributes :name, :created_at, :updated_at, :default_src_rewrite_rule, :default_src_rewrite_result,
             :default_dst_rewrite_rule, :default_dst_rewrite_result,
             :tag_action_value

  has_one :tag_action, class_name: 'TagAction'

  filter :name
end
