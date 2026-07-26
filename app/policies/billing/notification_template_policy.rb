# frozen_string_literal: true

module Billing
  class NotificationTemplatePolicy < ::RolePolicy
    section 'Billing/NotificationTemplate'

    alias_rule :preview?, to: :read?

    class Scope < ::RolePolicy::Scope
    end
  end
end
