# frozen_string_literal: true

module Jobs
  class StatsAggregation < ::BaseJob
    self.cron_line = '25 * * * *'

    def execute
      ::StatsAggregation::ActiveCall.call
      ::StatsAggregation::ActiveCallAccount.call
      ::StatsAggregation::ActiveCallOrigGateway.call
      ::StatsAggregation::ActiveCallTermGateway.call
    end
  end
end
