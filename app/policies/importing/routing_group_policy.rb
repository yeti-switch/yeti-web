# frozen_string_literal: true

module Importing
  class RoutingGroupPolicy < ::RolePolicy
    section 'Importing/RoutingGroup'

    class Scope < ::RolePolicy::Scope
    end
  end
end
