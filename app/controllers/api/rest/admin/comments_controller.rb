# frozen_string_literal: true

class Api::Rest::Admin::CommentsController < Api::Rest::Admin::BaseController
  before_action :authorize_comment_policy

  private

  def authorize_comment_policy
    policy = ActiveAdmin::CommentPolicy.new(current_admin_user, nil)
    allowed = action_name == 'create' ? policy.create? : policy.read?
    head 403 unless allowed
  end
end
