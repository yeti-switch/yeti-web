# frozen_string_literal: true

class Importing::ImportingDelayedJob
  QUEUE_NAME = 'import'

  JOB_STATE = { start: 'started', finish: 'finished', fail: 'FAILURE' }.freeze

  def initialize(klass, options)
    @klass = klass
    @options = options
  end

  def self.create_jobs(klass, options)
    options[:max_jobs_count] = ::GuiConfig.import_max_threads - 1
    (0..options[:max_jobs_count]).each do |job_number|
      options[:job_number] = job_number
      Delayed::Job.enqueue ::Importing::ImportingDelayedJob.new(klass, options)
    end
  end

  def self.jobs?
    Delayed::Job.where(queue: QUEUE_NAME, failed_at: nil).any?
  end

  def perform
    @klass.move_batch(@options)
  end

  def queue_name
    QUEUE_NAME
  end

  def max_attempts
    1
  end

  def destroy_failed_jobs
    false
  end

  def before(_job)
    write_log(JOB_STATE[:start])
  end

  def success(_job)
    write_log(JOB_STATE[:finish])
  end

  def error(_job, e)
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    write_log(e.message)
  end

  def failure(_job)
    write_log(JOB_STATE[:fail])
  end

  def write_log(status)
    # TODO: use AR
    ApplicationRecord.execute_sp(
      'select sys.logic_log(?, ?, ?)',
      "#{@klass.import_class} (#{@options[:job_number]})",
      0, status
    )
  end
end
