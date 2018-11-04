module Billing
  class AccountPackageCounterPolicy < ::RolePolicy
    section 'Billing/PackageCounterPolicy'

    class Scope < ::RolePolicy::Scope
    end

  end
end

