module Jobs
  class CdrPartitioning < ::BaseJob
    def execute
      Cdr::Table.add_partition
    end
  end
end
