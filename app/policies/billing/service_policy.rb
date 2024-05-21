# frozen_string_literal: true

module Billing
  class ServicePolicy < ::RolePolicy
    section 'Billing/Service'
    class Scope < ::RolePolicy::Scope
    end
  end
end
