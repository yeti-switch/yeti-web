# frozen_string_literal: true

module Equipment
  module StirShaken
    class TrustedRepositoryPolicy < ::RolePolicy
      section 'Equipment/StirShaken/TrustedRepository'

      alias_rule :enable?, :disable?, to: :perform? # DSL acts_as_status

      class Scope < ::RolePolicy::Scope
      end
    end
  end
end
