# frozen_string_literal: true

module RealtimeData
  class OutgoingRegistrationPolicy < ::RolePolicy
    section 'RealtimeData/OutgoingRegistration'

    class Scope < ::RolePolicy::Scope
    end
  end
end
