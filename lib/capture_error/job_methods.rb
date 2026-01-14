# frozen_string_literal: true

module CaptureError
  module JobMethods
    extend ActiveSupport::Concern
    include ::CaptureError::BaseMethods

    def capture_extra
      {
        active_job_class: self.class.name,
        active_job_id: job_id,
        arguments: arguments,
        scheduled_at: scheduled_at,
        exception_executions: exception_executions,
        executions: executions,
        provider_job_id: provider_job_id
      }
    end

    def capture_tags
      {
        active_job_queue: queue_name,
        provider_job_id: provider_job_id,
        active_job_class: self.class.name,
        active_job_id: job_id
      }
    end
  end
end
