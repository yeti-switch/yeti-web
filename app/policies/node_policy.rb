# frozen_string_literal: true

class NodePolicy < ::RolePolicy
  section 'Node'

  class Scope < ::RolePolicy::Scope
  end
end
