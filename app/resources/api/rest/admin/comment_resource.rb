# frozen_string_literal: true

class Api::Rest::Admin::CommentResource < BaseResource
  model_name 'ActiveAdmin::Comment'
  create_form 'AdminApi::CommentForm'

  attributes :body,
             :resource_type,
             :resource_id,
             :author_id,
             :created_at

  paginator :paged

  before_create { _model.author = context[:current_admin_user] }

  ransack_filter :resource_type, type: :string
  ransack_filter :resource_id, type: :string
  ransack_filter :author_id, type: :number
  ransack_filter :created_at, type: :datetime

  def self.records(options = {})
    super.where(namespace: AdminApi::CommentForm.namespace_name.to_s)
  end

  def self.creatable_fields(_context)
    %i[body resource_type resource_id]
  end

  def self.sortable_fields(_context)
    %i[id created_at]
  end
end
