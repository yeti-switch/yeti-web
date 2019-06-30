# frozen_string_literal: true

module PartitionModel
  class CdrPolicy < ::RolePolicy
    section 'Partition/Cdr'

    class Scope < ::RolePolicy::Scope
    end
  end
end
