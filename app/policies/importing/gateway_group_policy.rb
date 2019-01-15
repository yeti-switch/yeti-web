# frozen_string_literal: true

module Importing
  class GatewayGroupPolicy < ::RolePolicy
    section 'Importing/GatewayGroup'

    class Scope < ::RolePolicy::Scope
    end
  end
end
