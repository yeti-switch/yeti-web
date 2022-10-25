# frozen_string_literal: true

module System
  class EventSubscriptionPolicy < ::RolePolicy
    section 'System/EventSubscription'

    class Scope < ::RolePolicy::Scope
    end
  end
end
