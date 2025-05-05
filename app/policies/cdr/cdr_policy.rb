# frozen_string_literal: true

module Cdr
  class CdrPolicy < ::RolePolicy
    section 'Cdr/Cdr'
    self.allowed_actions += %i[allow_full_dst_number recording pcap]
    Scope = Class.new(RolePolicy::Scope)

    def routing_simulation?
      Routing::SimulationFormPolicy.new(user, nil).read?
    end

    def download_call_record?
      allowed_for_role?(:recording)
    end

    def dump?
      allowed_for_role?(:pcap)
    end

    def allow_full_dst_number?
      allowed_for_role?(:allow_full_dst_number)
    end
  end
end
