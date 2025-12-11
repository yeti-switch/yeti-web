# frozen_string_literal: true

module System
  class CustomerTokenPolicy < ::RolePolicy
    section 'System/CustomerToken'

    class Scope < ::RolePolicy::Scope
    end
  end
end
