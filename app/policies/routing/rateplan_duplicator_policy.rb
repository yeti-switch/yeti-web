# frozen_string_literal: true

module Routing
  class RateplanDuplicatorPolicy < ::RolePolicy
    section 'Routing/RateplanDuplicator'

    class Scope < ::RolePolicy::Scope
    end
  end
end
