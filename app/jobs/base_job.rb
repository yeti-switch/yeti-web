# frozen_string_literal: true

require_relative Rails.root.join('lib/scheduler/job/base').to_s

class BaseJob < Scheduler::Job::Base
  self.logger = Rails.logger

  include ::CaptureError::BaseMethods

  class_attribute :timeout, instance_writer: false, default: 1200

  class << self
    def type
      name.demodulize
    end

    def scheduler_options
      {
        overlap: false,
        name: type,
        timeout:
      }
    end
  end

  def call
    logger.tagged(self.class.name) do
      after_start
      execute
      before_finish
    end
  end

  def execute
    raise NotImplementedError
  end

  def before_finish; end

  def after_start; end

  def capture_job_extra(extra)
    CaptureError.with_exception_context(extra: { type => extra }) { yield }
  end
end
