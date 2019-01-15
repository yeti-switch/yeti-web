# frozen_string_literal: true

class PaymentPolicy < ::RolePolicy
  section 'Payment'

  class Scope < ::RolePolicy::Scope
  end
end
