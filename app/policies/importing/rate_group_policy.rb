# frozen_string_literal: true

module Importing
  class RateGroupPolicy < ::RolePolicy
    section 'Importing/RateGroup'

    class Scope < ::RolePolicy::Scope
    end
  end
end
