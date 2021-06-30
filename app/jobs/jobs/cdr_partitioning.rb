# frozen_string_literal: true

module Jobs
  class CdrPartitioning < ::BaseJob
    self.cron_line = '10 * * * *'

    def execute
      Cdr::Cdr.add_partitions
      Cdr::AuthLog.add_partitions
      Cdr::RtpStatistic.add_partitions
      Log::ApiLog.add_partitions
    end
  end
end
