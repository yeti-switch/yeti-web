# frozen_string_literal: true

class Api::Rest::Admin::Routing::NumberlistResource < ::BaseResource
  model_name 'Routing::Numberlist'

  attributes :name, :default_action_id, :mode_id,
             :created_at, :updated_at,
             :default_src_rewrite_rule, :default_src_rewrite_result, :defer_src_rewrite,
             :default_dst_rewrite_rule, :default_dst_rewrite_result, :defer_dst_rewrite,
             :tag_action_value, :external_id, :external_type

  paginator :paged

  has_one :tag_action, class_name: 'TagAction', always_include_linkage_data: true

  filter :name

  ransack_filter :name, type: :string
  ransack_filter :mode_id, type: :number
  ransack_filter :default_action_id, type: :number
  ransack_filter :created_at, type: :datetime
  ransack_filter :updated_at, type: :datetime
  ransack_filter :default_src_rewrite_rule, type: :string
  ransack_filter :default_src_rewrite_result, type: :string
  ransack_filter :defer_src_rewrite, type: :boolean
  ransack_filter :default_dst_rewrite_rule, type: :string
  ransack_filter :default_dst_rewrite_result, type: :string
  ransack_filter :defer_dst_rewrite, type: :boolean
  ransack_filter :external_id, type: :number
  ransack_filter :external_type, type: :string

  def self.creatable_fields(_context)
    %i[
      name
      default_action_id
      mode_id
      default_src_rewrite_rule
      default_src_rewrite_result
      defer_src_rewrite
      default_dst_rewrite_rule
      default_dst_rewrite_result
      defer_dst_rewrite
      tag_action_value
      external_id
      external_type
      tag_action
    ]
  end

  def self.updatable_fields(context)
    creatable_fields(context)
  end
end
