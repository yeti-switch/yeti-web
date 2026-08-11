# frozen_string_literal: true

module Billing
  class InvoiceEmailTemplatePolicy < ::RolePolicy
    section 'Billing/InvoiceEmailTemplate'

    alias_rule :preview?, to: :read?

    class Scope < ::RolePolicy::Scope
    end
  end
end
