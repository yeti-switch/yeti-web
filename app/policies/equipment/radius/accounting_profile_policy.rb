# frozen_string_literal: true

module Equipment
  module Radius
    class AccountingProfilePolicy < ::RolePolicy
      section 'Equipment/Radius/AccountingProfile'

      class Scope < ::RolePolicy::Scope
      end
    end
  end
end
