# frozen_string_literal: true

module Importing
  class DestinationPolicy < ::RolePolicy
    section 'Importing/Destination'

    class Scope < ::RolePolicy::Scope
    end
  end
end
