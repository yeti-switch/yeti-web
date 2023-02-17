# frozen_string_literal: true

module RateManagement
  class PricelistItemPolicy < PricelistPolicy
    section 'RateManagement'

    class Scope < ::RolePolicy::Scope
    end
  end
end
