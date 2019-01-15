# frozen_string_literal: true

module Log
  class ApiLogPolicy < ::RolePolicy
    section 'Log/ApiLog'

    class Scope < ::RolePolicy::Scope
    end
  end
end
