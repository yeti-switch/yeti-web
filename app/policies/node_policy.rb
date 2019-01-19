# frozen_string_literal: true

class NodePolicy < ::RolePolicy
  section 'Node'

  alias_rule :clear_cache?, to: :perform?

  class Scope < ::RolePolicy::Scope
  end
end
