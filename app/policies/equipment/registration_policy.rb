# frozen_string_literal: true

module Equipment
  class RegistrationPolicy < ::RolePolicy
    section 'Equipment/Registration'

    self.allowed_actions += %i[allow_auth_credentials]
    alias_rule :enable?, :disable?, to: :perform? # DSL acts_as_status

    def allow_auth_credentials?
      allowed_for_role?(:allow_auth_credentials)
    end

    class Scope < ::RolePolicy::Scope
    end
  end
end
