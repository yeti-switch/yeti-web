# frozen_string_literal: true

module Importing
  class RegistrationPolicy < ::RolePolicy
    section 'Importing/Registration'

    class Scope < ::RolePolicy::Scope
    end
  end
end
