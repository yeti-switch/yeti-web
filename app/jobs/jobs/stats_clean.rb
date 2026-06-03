# frozen_string_literal: true

module Jobs
  class StatsClean < ::BaseJob
    self.cron_line = '35 * * * *'

    def execute
      # Active-call stats are kept as raw per-minute snapshots (no hourly
      # rollup); charts reduce them client-side. Prune the raw tables here.
      Stats::ActiveCall.where('created_at < ?', ago).delete_all
      Stats::ActiveCallAccount.where('created_at < ?', ago).delete_all
      Stats::ActiveCallOrigGateway.where('created_at < ?', ago).delete_all
      Stats::ActiveCallTermGateway.where('created_at < ?', ago).delete_all
      Stats::TrafficCustomerAccount.where('timestamp < ?', ago).delete_all
      Stats::TrafficVendorAccount.where('timestamp < ?', ago).delete_all
      Stats::TerminationQualityStat.where('time_start < ?', quality_stats_period).delete_all
      Stats::CustomerAuthStats.where('timestamp < ?', ago).delete_all
      Log::ApiLog.where('created_at < ?', ago).delete_all
      Lnp::Cache.where('expires_at<now()').delete_all
    end

    def ago
      @ago ||= 1.month.ago
    end

    def quality_stats_period
      @quality_stats_period ||= 1.week.ago
    end
  end
end
