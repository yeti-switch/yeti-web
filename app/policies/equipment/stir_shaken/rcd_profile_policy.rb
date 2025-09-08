# frozen_string_literal: true

module Equipment
  module StirShaken
    class RcdProfilePolicy < ::RolePolicy
      section 'Equipment/StirShaken/RcdProfile'

      class Scope < ::RolePolicy::Scope
      end
    end
  end
end
