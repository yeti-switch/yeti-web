# frozen_string_literal: true

module Cnam
  class DatabasePolicy < ::RolePolicy
    section 'Cnam/Database'

    alias_rule :test_resolve?, to: :perform?

    class Scope < ::RolePolicy::Scope
    end
  end
end
