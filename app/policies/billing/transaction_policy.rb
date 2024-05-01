# frozen_string_literal: true

module Billing
  class TransactionPolicy < ::RolePolicy
    section 'Billing/Transaction'
    class Scope < ::RolePolicy::Scope
    end
  end
end
