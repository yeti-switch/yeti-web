# frozen_string_literal: true

require_relative './scheduler'
require_relative './prometheus/yeti_cron_job_processor'

class YetiScheduler < Scheduler::Base
  ConnectionsMiddleware = Class.new(Scheduler::Middleware::Base) do
    def call(options)
      ApplicationRecord.connection_pool.connection
      Cdr::Base.connection_pool.connection
      app.call(options)
      ApplicationRecord.connection_pool.release_connection
      Cdr::Base.connection_pool.release_connection
    end
  end
  PrometheusMiddleware = Class.new(Scheduler::Middleware::Base) do
    def call(options)
      app.call(options)
      if PrometheusConfig.enabled?
        YetiCronJobProcessor.collect(
          name: options.name,
          success: options.success,
          duration: options.duration
        )
      end
    end
  end
  DatabaseInfoMiddleware = Class.new(Scheduler::Middleware::Base) do
    def call(options)
      app.call(options)
      # DB Connections does not released yet.
      job_info = CronJobInfo.find_by!(name: options.name)
      job_info.update! attributes(options)
    end

    private

    def attributes(options)
      {
        last_run_at: options.started_at,
        last_duration: options.duration,
        last_exception: format_error(options.exception)
      }
    end

    def format_error(exception)
      return if exception.nil?

      "#{exception.class} #{exception.message}\n#{exception.backtrace&.join("\n")}"
    end
  end

  use ConnectionsMiddleware
  use DatabaseInfoMiddleware
  use PrometheusMiddleware
  self.logger = Rails.logger

  before_run do
    # close database connections if they were open.
    # main thread does not use database.
    # each time thread should acquire and release database connection.
    ApplicationRecord.clear_active_connections!
    ApplicationRecord.flush_idle_connections!
    Cdr::Base.clear_active_connections!
    Cdr::Base.flush_idle_connections!
  end

  on_error do |error, options|
    CaptureError.capture(
      error,
      tags: { component: 'YetiScheduler', job_name: options.name },
      extra: { options: options.to_h, scheduler_options: options.handler_class.scheduler_options }
    )
  end

  cron Jobs::CdrPartitioning
  cron Jobs::CdrBatchCleaner
  cron Jobs::PartitionRemoving
  cron Jobs::EventProcessor
  cron Jobs::CallsMonitoring
  cron Jobs::StatsClean
  cron Jobs::StatsAggregation
  cron Jobs::Invoice
  cron Jobs::ReportScheduler
  cron Jobs::TerminationQualityCheck
  cron Jobs::DialpeerRatesApply
  cron Jobs::AccountBalanceNotify
  cron Jobs::SyncDatabaseTables
  cron Jobs::DeleteExpiredDestinations
  cron Jobs::DeleteExpiredDialpeers
end
