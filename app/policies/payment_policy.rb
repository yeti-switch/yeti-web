# frozen_string_literal: true

class PaymentPolicy < ::RolePolicy
  section 'Payment'

  class Scope < ::RolePolicy::Scope
  end

  alias_rule :check_cryptomus?, to: :perform?
end
