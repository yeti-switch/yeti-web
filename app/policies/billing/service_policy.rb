# frozen_string_literal: true

module Billing
  class ServicePolicy < ::RolePolicy
    section 'Billing/Service'

    def update?
      allowed_for_role?(:change)
    end

    def edit?
      allowed_for_role?(:change) && !record.terminated?
    end

    def terminate?
      allowed_for_role?(:change) && !record.terminated?
    end

    class Scope < ::RolePolicy::Scope
    end
  end
end
