# frozen_string_literal: true

module Billing
  class ServiceTypePolicy < ::RolePolicy
    section 'Billing/ServiceType'
    class Scope < ::RolePolicy::Scope
    end
  end
end
