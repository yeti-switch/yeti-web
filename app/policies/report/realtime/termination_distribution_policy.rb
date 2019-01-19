# frozen_string_literal: true

module Report
  module Realtime
    class TerminationDistributionPolicy < ::RolePolicy
      section 'Report/Realtime/TerminationDistribution'

      class Scope < ::RolePolicy::Scope
      end
    end
  end
end
