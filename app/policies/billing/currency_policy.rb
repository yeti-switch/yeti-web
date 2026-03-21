# frozen_string_literal: true

module Billing
  class CurrencyPolicy < ::RolePolicy
    section 'Billing/Currency'
    class Scope < ::RolePolicy::Scope
    end
  end
end
