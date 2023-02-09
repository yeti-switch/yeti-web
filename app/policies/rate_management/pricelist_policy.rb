# frozen_string_literal: true

module RateManagement
  class PricelistPolicy < ::RolePolicy
    section 'RateManagement'

    alias_rule :redetect_dialpeers?, :detect_dialpeers?, :apply_changes?, to: :perform?

    class Scope < ::RolePolicy::Scope
    end
  end
end
