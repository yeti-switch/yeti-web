module RealtimeData
  class ActiveCallPolicy < ::RolePolicy
    section 'RealtimeData/ActiveCall'

    alias_rule :drop?, to: :perform?

    class Scope < ::RolePolicy::Scope
    end

  end
end
  
