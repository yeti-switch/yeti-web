# frozen_string_literal: true

module System
  class SchedulerPolicy < ::RolePolicy
    section 'System/Scheduler'

    class Scope < ::RolePolicy::Scope
    end
  end
end
