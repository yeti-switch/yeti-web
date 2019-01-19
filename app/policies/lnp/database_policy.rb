# frozen_string_literal: true

module Lnp
  class DatabasePolicy < ::RolePolicy
    section 'Lnp/Database'

    alias_rule :test_resolve?, to: :perform?

    class Scope < ::RolePolicy::Scope
    end
  end
end
