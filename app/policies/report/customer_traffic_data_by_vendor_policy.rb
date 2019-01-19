# frozen_string_literal: true

module Report
  class CustomerTrafficDataByVendorPolicy < ::RolePolicy
    section 'Report/CustomerTrafficDataByVendor'

    class Scope < ::RolePolicy::Scope
    end
  end
end
