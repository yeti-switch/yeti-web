# frozen_string_literal: true

module RtpStatistics
  class RxStreamPolicy < ::RolePolicy
    section 'RtpStatistics/RxStream'

    class Scope < ::RolePolicy::Scope
    end
  end
end
