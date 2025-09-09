# frozen_string_literal: true

class CdrExportPolicy < ::RolePolicy
  section 'CdrExport'

  alias_rule :download?, to: :perform?
  alias_rule :delete_file?, to: :destroy?
  alias_rule :retry?, to: :create?

  class Scope < ::RolePolicy::Scope
  end
end
