# frozen_string_literal: true

module Cdr
  class TablePolicy < ::RolePolicy
    section 'Cdr/Table'

    alias_rule :unload?, to: :perform?

    class Scope < ::RolePolicy::Scope
    end
  end
end
