# frozen_string_literal: true

module Routing
  class RoutingGroupPolicy < ::RolePolicy
    section 'Routing/RoutingGroup'

    class Scope < ::RolePolicy::Scope
    end
  end
end
