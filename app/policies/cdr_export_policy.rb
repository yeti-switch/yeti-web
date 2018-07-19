class CdrExportPolicy < ::RolePolicy
  section 'CdrExport'

  alias_rule :download?, to: :perform?

  class Scope < ::RolePolicy::Scope
  end

end

