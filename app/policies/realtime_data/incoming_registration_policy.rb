# frozen_string_literal: true

module RealtimeData
  class IncomingRegistrationPolicy < ::RolePolicy
    section 'RealtimeData/IncomingRegistration'

    class Scope < ::RolePolicy::Scope
    end
  end
end
