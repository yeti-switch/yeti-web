module Cdr
  class CdrArchivePolicy < ::RolePolicy
    section 'Cdr/CdrArchive'

    alias_rule :dump?, :debug?, to: :perform?

    class Scope < ::RolePolicy::Scope
    end

  end
end
  
