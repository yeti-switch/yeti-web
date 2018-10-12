module Importing
  class CustomersAuthPolicy < ::RolePolicy
    section 'Importing/CustomersAuth'

    class Scope < ::RolePolicy::Scope
    end

  end
end
  
