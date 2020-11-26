# frozen_string_literal: true

module Equipment
  class SipOptionsProberPolicy < ::RolePolicy
    section 'Equipment/SipOptionsProber'

    alias_rule :enable?, :disable?, to: :perform? # DSL acts_as_status

    class Scope < ::RolePolicy::Scope
    end
  end
end
