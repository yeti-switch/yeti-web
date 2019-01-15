# frozen_string_literal: true

module Report
  class CustomCdrSchedulerPolicy < ::RolePolicy
    section 'Report/CustomCdrScheduler'

    class Scope < ::RolePolicy::Scope
    end
  end
end
