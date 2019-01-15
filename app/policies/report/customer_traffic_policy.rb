# frozen_string_literal: true

module Report
  class CustomerTrafficPolicy < ::RolePolicy
    section 'Report/CustomerTraffic'

    class Scope < ::RolePolicy::Scope
    end
  end
end
