# frozen_string_literal: true

module RealtimeData
  class ActiveNodePolicy < ::RolePolicy
    section 'RealtimeData/ActiveNode'

    class Scope < ::RolePolicy::Scope
    end
  end
end
