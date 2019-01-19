# frozen_string_literal: true

module Log
  class BalanceNotificationPolicy < ::RolePolicy
    section 'Log/BalanceNotification'

    class Scope < ::RolePolicy::Scope
    end
  end
end
