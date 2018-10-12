class AdminUserPolicy < RolePolicy
  class Scope < RolePolicy::Scope
  end

  alias_rule :enabled?, :disabled?, to: :perform? # DSL acts_as_status

  private

  def section_name
    if user.id == record.id
      :'System/AdminUser/Self'
    else
      :'System/AdminUser'
    end
  end
end
