# frozen_string_literal: true

module Worker
  class CaptureErrorJob < ::ApplicationJob
    self.queue_adapter = :async
    queue_as :capture_error

    rescue_from StandardError, with: :log_error

    retry_on CaptureError::Errors::SentFailed,
             wait: 1.minute,
             attempts: 5

    def perform(event)
      return unless CaptureError.enabled?

      Raven.send_event(event)
    end
  end
end
