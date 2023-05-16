# frozen_string_literal: true

class Api::Rest::Admin::Routing::NumberlistItemResource < ::BaseResource
  model_name 'Routing::NumberlistItem'

  attributes :key, :number_min_length, :number_max_length,
             :action_id,
             :src_rewrite_rule, :src_rewrite_result, :defer_src_rewrite,
             :dst_rewrite_rule, :dst_rewrite_result, :defer_dst_rewrite,
             :tag_action_value, :created_at, :updated_at

  paginator :paged

  has_one :numberlist, class_name: 'Numberlist'
  has_one :tag_action, class_name: 'TagAction'

  relationship_filter :numberlist

  filter :key # DEPRECATED

  ransack_filter :key, type: :string
  ransack_filter :action_id, type: :number
  ransack_filter :created_at, type: :datetime
  ransack_filter :updated_at, type: :datetime
  ransack_filter :src_rewrite_rule, type: :string
  ransack_filter :src_rewrite_result, type: :string
  ransack_filter :defer_src_rewrite, type: :boolean
  ransack_filter :dst_rewrite_rule, type: :string
  ransack_filter :dst_rewrite_result, type: :string
  ransack_filter :defer_dst_rewrite, type: :boolean
  ransack_filter :number_min_length, type: :number
  ransack_filter :number_max_length, type: :number
end
