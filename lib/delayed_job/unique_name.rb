# frozen_string_literal: true

module Delayed::UniqueNamePatch
  extend ActiveSupport::Concern

  class_methods do
    # Original scope returns scope of job that are
    # not locked or locked more than max_run_time period or locked by current delayed_job instance.
    # We exclude jobs that have unique_name != null if job with same unique_name is running right now.
    #
    # SELECT *
    # FROM delayed_jobs
    # WHERE
    #   (
    #     (run_at <= '2022-02-22 11:23:57.418827' AND (locked_at IS NULL OR locked_at < '2022-02-22 07:23:57.418836'))
    #     OR
    #     locked_by = 'host:pid'
    #   )
    #   AND
    #     failed_at IS NULL
    #   AND
    #   (
    #     unique_name IS NULL
    #     OR
    #     unique_name NOT IN (
    #       SELECT DISTINCT unique_name
    #       FROM delayed_jobs
    #       WHERE
    #         (locked_at IS NOT NULL AND locked_at >= '2022-02-22 07:23:57.408854' AND locked_by != 'host:pid')
    #         AND
    #         (unique_name IS NOT NULL)
    #     )
    #   )
    def ready_to_run(worker_name, max_run_time)
      unique_name_select = unique_name_running(worker_name, max_run_time)
      super.where("unique_name IS NULL OR unique_name NOT IN (#{unique_name_select.to_sql})")
    end

    # Returns sql statement with select of currently running unique_name.
    #
    # SELECT DISTINCT unique_name
    # FROM delayed_jobs
    # WHERE
    #   (locked_at IS NOT NULL AND locked_at >= '2022-02-22 07:23:57.408854' AND locked_by != 'host:pid')
    #   AND
    #   (unique_name IS NOT NULL)
    def unique_name_running(worker_name, max_run_time)
      currently_running(worker_name, max_run_time).where('unique_name IS NOT NULL').select('DISTINCT unique_name')
    end

    # Returns scope of jobs that are currently runing by other delayed_job instances.
    # Opposite to original ready_to_run scope.
    # SELECT *
    # FROM delayed_jobs
    # WHERE
    #   locked_at IS NOT NULL
    #   AND
    #   locked_at >= '2022-02-22 07:23:57.408854'
    #   AND
    #   locked_by != 'host:pid'
    def currently_running(worker_name, max_run_time)
      Delayed::Job.where('locked_at IS NOT NULL AND locked_at >= ? AND locked_by != ?', db_time_now - max_run_time, worker_name)
    end
  end
end

class Delayed::UniqueNamePlugin < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.before(:enqueue) do |job|
      job.unique_name = find_unique_name(job)
    end
  end

  def self.find_unique_name(job)
    return unless job.payload_object.respond_to?(:job_data)

    active_job_class = job.payload_object.job_data['job_class'].safe_constantize
    return if active_job_class.nil?
    return unless active_job_class.respond_to?(:_unique_name)

    active_job_class._unique_name
  end
end

Delayed::Job.prepend Delayed::UniqueNamePatch
Delayed::Worker.plugins << Delayed::UniqueNamePlugin
