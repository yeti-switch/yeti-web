# frozen_string_literal: true

module Routing
  class TrafficSamplingRulePolicy < ::RolePolicy
    section 'Routing/TrafficSamplingRule'

    class Scope < ::RolePolicy::Scope
    end
  end
end
