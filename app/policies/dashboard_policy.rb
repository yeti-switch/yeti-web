# frozen_string_literal: true

class DashboardPolicy < RolePolicy
  Scope = Class.new(RolePolicy::Scope)

  def details?
    allowed_for_role?(:details)
  end
end
