# frozen_string_literal: true

module PartitionModel
  class LogPolicy < ::RolePolicy
    section 'Partition/Log'

    class Scope < ::RolePolicy::Scope
    end
  end
end
