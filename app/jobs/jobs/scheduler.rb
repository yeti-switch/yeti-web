# frozen_string_literal: true

module Jobs
  class Scheduler < ::BaseJob
    self.cron_line = '*/2 * * * *'

    def execute
      System::Scheduler.all.find_each(&:check)
    end
  end
end
