# frozen_string_literal: true

module Cdr
  class CdrPolicy < ::RolePolicy
    section 'Cdr/Cdr'

    alias_rule :dump?, :routing_simulation?, to: :perform?
    alias_rule :download_call_record?, :download_call_record?, to: :perform?

    class Scope < ::RolePolicy::Scope
    end
  end
end
