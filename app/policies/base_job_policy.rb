class BaseJobPolicy < ::RolePolicy
  section 'BaseJob'

  alias_rule :run?, :unlock?, to: :perform?

  class Scope < ::RolePolicy::Scope
  end

end

