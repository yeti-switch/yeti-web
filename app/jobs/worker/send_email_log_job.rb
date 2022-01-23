# frozen_string_literal: true

module Worker
  class SendEmailLogJob < ::ApplicationJob
    queue_as 'email_log'

    def perform(email_log_id)
      YetiMail.email_message(email_log_id).deliver!
      Log::EmailLog.where(id: email_log_id).update_all(sent_at: Time.now)
    rescue StandardError => e
      Rails.logger.warn { "<#{e.class}>: #{e.message}" }
      Rails.logger.warn { e.backtrace.join("\n") }
      capture_error(e)
      Log::EmailLog.where(id: email_log_id).update_all(error: e.message)
    end
  end
end
