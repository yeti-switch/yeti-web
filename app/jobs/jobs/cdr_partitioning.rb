# frozen_string_literal: true

module Jobs
  class CdrPartitioning < ::BaseJob
    def execute
      Cdr::Table.add_partition
      Cdr::AuthLogTable.add_partition
    end
  end
end
