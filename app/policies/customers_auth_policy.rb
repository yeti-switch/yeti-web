# frozen_string_literal: true

class CustomersAuthPolicy < ::RolePolicy
  section 'CustomersAuth'

  self.allowed_actions += %i[recording pcap]

  alias_rule :enable?, :disable?, to: :perform? # DSL acts_as_status

  def recording?
    allowed_for_role?(:recording)
    end

  def pcap?
    allowed_for_role?(:pcap)
  end

  class Scope < ::RolePolicy::Scope
  end
end
