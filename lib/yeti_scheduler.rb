# frozen_string_literal: true

require 'scheduler'
require 'prometheus_config'
require 'prometheus/yeti_cron_job_processor'
require 'prometheus/yeti_info_processor'

class YetiScheduler < Scheduler::Base
  CaptureErrorMiddleware = Class.new(Scheduler::Middleware::Base) do
    def call(options)
      context = capture_context(options)
      CaptureError.with_clean_context(context) { app.call(options) }
    end

    private

    def capture_context(options)
      {
        tags: { component: 'YetiScheduler', job_name: options.name },
        extra: { options: options.to_h, scheduler_options: options.handler_class.scheduler_options }
      }
    end
  end
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

  use CaptureErrorMiddleware
  use ConnectionsMiddleware
  use DatabaseInfoMiddleware
  use PrometheusMiddleware
  self.logger = Rails.logger

  before_run do
    # close database connections if they were open.
    # main thread does not use database.
    # each time thread should acquire and release database connection.
    ApplicationRecord.connection_handler.clear_active_connections!(:all)
    ApplicationRecord.connection_handler.flush_idle_connections!(:all)
    Cdr::Base.connection_handler.clear_active_connections!(:all)
    Cdr::Base.connection_handler.flush_idle_connections!(:all)

    if PrometheusConfig.enabled?
      YetiInfoProcessor.start(labels: { app_type: 'scheduler' })
    end
  end

  on_error do |error, _options|
    CaptureError.capture(error)
  end

  cron Jobs::CdrPartitioning
  cron Jobs::CdrBatchCleaner
  cron Jobs::PartitionRemoving
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
  cron Jobs::DeleteBalanceNotifications
  cron Jobs::DeleteAppliedRateManagementPricelists
  cron Jobs::ServiceRenew
  every Jobs::PrometheusCustomerAuthStats
end
