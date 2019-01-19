# frozen_string_literal: true

module System
  class NetworkPrefixPolicy < ::RolePolicy
    section 'System/NetworkPrefix'

    class Scope < ::RolePolicy::Scope
    end
  end
end
