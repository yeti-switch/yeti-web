# frozen_string_literal: true

class CustomersAuthPolicy < ::RolePolicy
  section 'CustomersAuth'

  alias_rule :enable?, :disable?, to: :perform? # DSL acts_as_status

  class Scope < ::RolePolicy::Scope
  end
end
