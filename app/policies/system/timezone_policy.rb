# frozen_string_literal: true

module System
  class TimezonePolicy < ::RolePolicy
    section 'System/TimeZone'

    class Scope < ::RolePolicy::Scope
    end
  end
end
