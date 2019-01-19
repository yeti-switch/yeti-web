# frozen_string_literal: true

class AccountPolicy < ::RolePolicy
  section 'Account'

  alias_rule :payment?, to: :perform?

  class Scope < ::RolePolicy::Scope
  end
end
