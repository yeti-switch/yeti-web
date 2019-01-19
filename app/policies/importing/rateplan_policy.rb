# frozen_string_literal: true

module Importing
  class RateplanPolicy < ::RolePolicy
    section 'Importing/Rateplan'

    class Scope < ::RolePolicy::Scope
    end
  end
end
