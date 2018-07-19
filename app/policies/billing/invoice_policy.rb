module Billing
  class InvoicePolicy < ::RolePolicy
    section 'Billing/Invoice'

    class Scope < ::RolePolicy::Scope
    end

  end
end
  
