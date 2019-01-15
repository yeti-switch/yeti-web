# frozen_string_literal: true

module Report
  class CustomCdrPolicy < ::RolePolicy
    section 'Report/CustomCdr'

    class Scope < ::RolePolicy::Scope
    end
  end
end
