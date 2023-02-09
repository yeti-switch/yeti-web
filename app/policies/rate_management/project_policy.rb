# frozen_string_literal: true

module RateManagement
  class ProjectPolicy < ::RolePolicy
    section 'RateManagement'

    class Scope < ::RolePolicy::Scope
    end
  end
end
