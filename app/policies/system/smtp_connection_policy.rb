module System
  class SmtpConnectionPolicy < ::RolePolicy
    section 'System/SmtpConnection'

    alias_rule :send_email?, to: :perform?

    class Scope < ::RolePolicy::Scope
    end

  end
end
  
