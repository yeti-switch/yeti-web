# frozen_string_literal: true

module Stats
  class CustomerAuthStatsPolicy < ::RolePolicy
    section 'Report/CustomerAuthStatistic'

    class Scope < ::RolePolicy::Scope
    end
  end
end
