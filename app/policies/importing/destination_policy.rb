# frozen_string_literal: true

module Importing
  class DestinationPolicy < ::RolePolicy
    section 'Importing/Destination'

    self.allowed_actions += %i[hide_cdo]

    def allow_cdo?
      !allowed_for_role?(:hide_cdo)
    end

    class Scope < ::RolePolicy::Scope
    end
  end
end
