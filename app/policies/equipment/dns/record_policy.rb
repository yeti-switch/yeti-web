# frozen_string_literal: true

module Equipment
  module Dns
    class RecordPolicy < ::RolePolicy
      section 'Equipment/Dns/Record'

      class Scope < ::RolePolicy::Scope
      end
    end
  end
end
