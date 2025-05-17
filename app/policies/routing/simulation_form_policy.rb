# frozen_string_literal: true

module Routing
  class SimulationFormPolicy < RolePolicy
    section 'Routing/RoutingSimulation'

    def read?
      allowed_for_role?(:read)
    end

    Scope = Class.new(RolePolicy::Scope)
  end
end
