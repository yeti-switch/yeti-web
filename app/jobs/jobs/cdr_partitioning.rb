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
      day = Date.today
      3.times do
        prefix = day.to_s(:db).gsub('-', '_')
        Cdr::RtpStatistic.add_partition(prefix, day.beginning_of_day, day.end_of_day)
        day += 1
      end
    end
  end
end
