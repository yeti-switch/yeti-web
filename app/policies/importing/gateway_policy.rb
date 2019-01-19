# frozen_string_literal: true

module Importing
  class GatewayPolicy < ::RolePolicy
    section 'Importing/Gateway'

    class Scope < ::RolePolicy::Scope
    end
  end
end
