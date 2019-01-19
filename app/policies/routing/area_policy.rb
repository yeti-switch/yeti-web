# frozen_string_literal: true

module Routing
  class AreaPolicy < ::RolePolicy
    section 'Routing/Area'

    class Scope < ::RolePolicy::Scope
    end
  end
end
