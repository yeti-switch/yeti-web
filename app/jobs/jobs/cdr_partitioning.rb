# frozen_string_literal: true

module Jobs
  class CdrPartitioning < ::BaseJob
    def execute
      Cdr::Table.add_partition
      Cdr::AuthLogTable.add_partition
      rtp_statistic_add_partition
    end

    private

    def rtp_statistic_add_partition
      from = Date.today
      3.times do
        prefix = from.to_s(:db).gsub('-', '_')
        Cdr::RtpStatistic.add_partition(prefix, from, from + 1)
        from += 1
      end
    end
  end
end
