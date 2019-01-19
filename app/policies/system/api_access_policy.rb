# frozen_string_literal: true

module System
  class ApiAccessPolicy < ::RolePolicy
    section 'System/ApiAccess'

    class Scope < ::RolePolicy::Scope
    end
  end
end
