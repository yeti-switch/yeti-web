# frozen_string_literal: true

class AdminUserPolicy < RolePolicy
  class Scope < RolePolicy::Scope
  end

  alias_rule :enable?, :disable?, to: :perform? # DSL acts_as_status
  alias_rule :change_password?, to: :submit_password?

  def submit_password?
    myself? && read?
  end

  private

  def section_name
    if myself?
      :'System/AdminUser/Self'
    else
      :'System/AdminUser'
    end
  end

  def myself?
    user.id == record.id
  end
end
