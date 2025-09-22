# frozen_string_literal: true

module Cdr
  class CdrCompactedTablePolicy < ::RolePolicy
    section 'Cdr/CdrCompactedTable'
    Scope = Class.new(RolePolicy::Scope)
  end
end
