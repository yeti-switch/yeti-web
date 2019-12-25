# frozen_string_literal: true

module Equipment
  class RegistrationPolicy < ::RolePolicy
    section 'Equipment/Registration'

    alias_rule :enable?, :disable?, to: :perform? # DSL acts_as_status

    class Scope < ::RolePolicy::Scope
    end
  end
end
