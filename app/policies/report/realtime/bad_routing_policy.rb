# frozen_string_literal: true

module Report
  module Realtime
    class BadRoutingPolicy < ::RolePolicy
      section 'Report/Realtime/BadRouting'

      class Scope < ::RolePolicy::Scope
      end
    end
  end
end
