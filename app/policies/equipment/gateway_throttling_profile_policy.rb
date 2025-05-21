# frozen_string_literal: true

module Equipment
  class GatewayThrottlingProfilePolicy < ::RolePolicy
    section 'Equipment/GatewayThrottlingProfile'

    class Scope < ::RolePolicy::Scope
    end
  end
end
