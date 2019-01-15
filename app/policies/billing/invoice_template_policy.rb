# frozen_string_literal: true

module Billing
  class InvoiceTemplatePolicy < ::RolePolicy
    section 'Billing/InvoiceTemplate'

    alias_rule :download?, to: :perform?

    class Scope < ::RolePolicy::Scope
    end
  end
end
