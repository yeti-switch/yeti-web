# frozen_string_literal: true

require 'rufus-scheduler'

class CronScheduler
  CronJob = Struct.new(:cron_time, :job_class_name)

  class_attribute :jobs, instance_accessor: false, default: []
  class_attribute :_current_scheduler, instance_accessor: false
  class_attribute :logger, instance_writer: false, default: Rails.logger

  def self.register_job(cron_time, job_class_name)
    jobs.push CronJob.new(cron_time, job_class_name)
  end

  register_job '10 * * * *', 'CdrPartitioning'
  register_job '*/30 * * * *', 'CdrBatchCleaner'
  register_job '20 * * * *', 'PartitionRemoving'
  register_job '* * * * *', 'EventProcessor'
  register_job '* * * * *', 'CallsMonitoring'
  register_job '35 * * * *', 'StatsClean'
  register_job '25 * * * *', 'StatsAggregation'
  register_job '30 5 * * *', 'Invoice'
  register_job '*/15 * * * *', 'ReportScheduler'
  register_job '*/16 * * * *', 'TerminationQualityCheck'
  register_job '* * * * *', 'DialpeerRatesApply'
  register_job '* * * * *', 'AccountBalanceNotify'
  register_job '0 2 * * *', 'SyncDatabaseTables'

  def self.start!
    raise ArgumentError, "#{name} already started." if _current_scheduler

    # close database connections if they were open.
    # main thread does not use database.
    # each time thread should acquire and release database connection.
    Yeti::ActiveRecord.clear_active_connections!
    Yeti::ActiveRecord.flush_idle_connections!
    Cdr::Base.clear_active_connections!
    Cdr::Base.flush_idle_connections!

    self._current_scheduler = Rufus::Scheduler.new

    jobs.each do |job|
      _current_scheduler.cron(job.cron_time) { new(job).run! }
    end

    logger.info { "#{name} process started." }

    _current_scheduler.join
  end

  attr_reader :job
  delegate :job_class_name, to: :job

  def initialize(job)
    @job = job
  end

  def run!
    logger.tagged(self.class.name) do
      wrap_connections { launch_job! }
    end
  end

  private

  def launch_job!
    logger.info { "Started cron job #{job_class_name}." }
    BaseJob.launch!(job_class_name)
    logger.info { "Cron job #{job_class_name} was performed successfully." }
  rescue StandardError => e
    logger.error { "Cron job #{job_class_name} was performed with an exception." }
    logger.error { "#{e.class}>: #{e.message}\n#{e.backtrace&.join("\n")}" }
  end

  def wrap_connections
    Yeti::ActiveRecord.connection_pool.with_connection do
      Cdr::Base.connection_pool.with_connection { yield }
    end
  end
end
