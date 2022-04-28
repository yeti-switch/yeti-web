# frozen_string_literal: true

module Worker
  class CaptureErrorJob < ::ApplicationJob
    self.queue_adapter = :async
    queue_as :capture_error

    rescue_from StandardError, with: :log_error

    retry_on 'Sentry::Error',
             wait: 1.minute,
             attempts: 5

    def perform(event, hint)
      return unless CaptureError.enabled?

      Sentry.send_event(event, hint)
    end
  end
end
