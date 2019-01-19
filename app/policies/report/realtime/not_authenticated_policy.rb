# frozen_string_literal: true

module Report
  module Realtime
    class NotAuthenticatedPolicy < ::RolePolicy
      section 'Report/Realtime/NotAuthenticated'

      class Scope < ::RolePolicy::Scope
      end
    end
  end
end
