# frozen_string_literal: true

class PaymentPolicy < ::RolePolicy
  section 'Payment'

  class Scope < ::RolePolicy::Scope
  end

  def rollback?
    allowed_for_role?(:rollback)
  end

  alias_rule :check_cryptomus?, to: :perform?
end
