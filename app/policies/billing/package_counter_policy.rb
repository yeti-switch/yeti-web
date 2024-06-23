# frozen_string_literal: true

module Billing
  class PackageCounterPolicy < ::RolePolicy
    section 'Billing/PackageCounter'
    class Scope < ::RolePolicy::Scope
    end
  end
end
