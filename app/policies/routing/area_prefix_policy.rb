# frozen_string_literal: true

module Routing
  class AreaPrefixPolicy < ::RolePolicy
    section 'Routing/AreaPrefix'

    class Scope < ::RolePolicy::Scope
    end
  end
end
