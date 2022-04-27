# frozen_string_literal: true

module RtpStatistics
  class TxStreamPolicy < ::RolePolicy
    section 'RtpStatistics/TxStream'

    class Scope < ::RolePolicy::Scope
    end
  end
end
