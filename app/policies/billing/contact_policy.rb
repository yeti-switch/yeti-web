# frozen_string_literal: true

module Billing
  class ContactPolicy < ::RolePolicy
    section 'Billing/Contact'

    class Scope < ::RolePolicy::Scope
    end
  end
end
