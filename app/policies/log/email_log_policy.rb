# frozen_string_literal: true

module Log
  class EmailLogPolicy < ::RolePolicy
    section 'Log/EmailLog'

    alias_rule :export?, to: :perform?

    class Scope < ::RolePolicy::Scope
    end
  end
end
