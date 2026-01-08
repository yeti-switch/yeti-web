# frozen_string_literal: true

module Equipment
  module Dns
    class ZonePolicy < ::RolePolicy
      section 'Equipment/Dns/Zone'

      class Scope < ::RolePolicy::Scope
      end
    end
  end
end
