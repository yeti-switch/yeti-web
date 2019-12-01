# frozen_string_literal: true

module CaptureError
  module JobMethods
    extend ActiveSupport::Concern
    include ::CaptureError::BaseMethods

    def capture_extra
      dj = Delayed::Job.find_by(id: provider_job_id) if provider_job_id.present?
      {
        active_job_class: self.class.name,
        active_job_id: job_id,
        arguments: arguments,
        scheduled_at: scheduled_at,
        delayed_job: {
          id: provider_job_id,
          priority: dj&.priority,
          attempts: dj&.attempts,
          run_at: dj&.run_at,
          locked_at: dj&.locked_at,
          locked_by: dj&.locked_by,
          queue: dj&.queue,
          created_at: dj&.created_at
        }
      }
    end

    def capture_tags
      {
        delayed_job_queue: queue_name,
        delayed_job_id: provider_job_id,
        active_job_class: self.class.name,
        active_job_id: job_id
      }
    end
  end
end
