# frozen_string_literal: true

module Importing
  class DisconnectPolicyPolicy < ::RolePolicy
    section 'Importing/DisconnectPolicy'

    class Scope < ::RolePolicy::Scope
    end
  end
end
