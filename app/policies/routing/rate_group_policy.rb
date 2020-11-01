# frozen_string_literal: true

module Routing
  class RateGroupPolicy < ::RolePolicy
    section 'Routing/RateGroup'

    class Scope < ::RolePolicy::Scope
    end
  end
end
