# frozen_string_literal: true

module Importing
  class AccountPolicy < ::RolePolicy
    section 'Importing/Account'

    class Scope < ::RolePolicy::Scope
    end
  end
end
