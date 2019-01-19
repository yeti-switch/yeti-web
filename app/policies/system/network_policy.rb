# frozen_string_literal: true

module System
  class NetworkPolicy < ::RolePolicy
    section 'System/Network'

    class Scope < ::RolePolicy::Scope
    end
  end
end
