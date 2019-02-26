# frozen_string_literal: true

module ActiveAdmin
  class CommentPolicy < ::RolePolicy
    section 'ActiveAdmin/Comment'

    class Scope < ::RolePolicy::Scope
    end
  end
end