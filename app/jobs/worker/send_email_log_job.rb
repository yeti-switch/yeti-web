# frozen_string_literal: true

module Worker
  class SendEmailLogJob < ::ApplicationJob
    queue_as 'email_log'

    def perform(email_log_id)
      email_log = Log::EmailLog.find(email_log_id)
      YetiMail.email_message(email_log).deliver!
      email_log.update!(sent_at: Time.now)
    rescue StandardError => e
      error_message = "<#{e.class}>: #{e.message}\n#{e.backtrace&.join("\n")}"
      Rails.logger.error { error_message }
      capture_error(e)
      email_log&.update!(error: error_message)
    end
  end
end
