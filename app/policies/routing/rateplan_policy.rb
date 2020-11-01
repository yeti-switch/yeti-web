# frozen_string_literal: true

module Routing
  class RateplanPolicy < ::RolePolicy
    section 'Routing/Rateplan'

    class Scope < ::RolePolicy::Scope
    end
  end
end
