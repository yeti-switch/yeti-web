# frozen_string_literal: true

module Yeti
  class TimeZoneHelperPolicy < ::RolePolicy
    section 'Yeti/TimeZoneHelper'

    class Scope < ::RolePolicy::Scope
    end
  end
end
