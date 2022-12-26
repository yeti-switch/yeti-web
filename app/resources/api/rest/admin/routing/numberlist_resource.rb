# frozen_string_literal: true

class Api::Rest::Admin::Routing::NumberlistResource < ::BaseResource
  model_name 'Routing::Numberlist'

  attributes :name, :default_action_id, :mode_id,
             :created_at, :updated_at, :default_src_rewrite_rule, :default_src_rewrite_result,
             :default_dst_rewrite_rule, :default_dst_rewrite_result,
             :tag_action_value, :external_id

  paginator :paged

  has_one :tag_action, class_name: 'TagAction'

  filter :name

  ransack_filter :name, type: :string
  ransack_filter :mode_id, type: :number
  ransack_filter :default_action_id, type: :number
  ransack_filter :created_at, type: :datetime
  ransack_filter :updated_at, type: :datetime
  ransack_filter :default_src_rewrite_rule, type: :string
  ransack_filter :default_src_rewrite_result, type: :string
  ransack_filter :default_dst_rewrite_rule, type: :string
  ransack_filter :default_dst_rewrite_result, type: :string
  ransack_filter :external_id, type: :number
end
