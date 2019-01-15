# frozen_string_literal: true

module Report
  module Realtime
    class OriginationPerformancePolicy < ::RolePolicy
      section 'Report/Realtime/OriginationPerformance'

      class Scope < ::RolePolicy::Scope
      end
    end
  end
end
