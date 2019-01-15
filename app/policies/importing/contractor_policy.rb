# frozen_string_literal: true

module Importing
  class ContractorPolicy < ::RolePolicy
    section 'Importing/Contractor'

    class Scope < ::RolePolicy::Scope
    end
  end
end
