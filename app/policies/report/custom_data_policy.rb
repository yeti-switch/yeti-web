# frozen_string_literal: true

module Report
  class CustomDataPolicy < ::RolePolicy
    section 'Report/CustomData'

    class Scope < ::RolePolicy::Scope
    end
  end
end
