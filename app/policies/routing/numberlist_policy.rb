# frozen_string_literal: true

module Routing
  class NumberlistPolicy < ::RolePolicy
    section 'Routing/Numberlist'

    class Scope < ::RolePolicy::Scope
    end
  end
end
