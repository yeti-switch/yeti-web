# frozen_string_literal: true

module Concerns::ErrorNotify
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :notify_error unless Rails.env.development?
  end

  def notify_error(e, re_raise = true)
    Rails.logger.error e.message
    Rails.logger.warn e.backtrace.join("\n")
    ActionMailer::Base.mail(subject: e.message,
                            body: [e.backtrace.join("\n"), request.inspect].join("\n\n\n")).deliver
    raise e if re_raise
  end
end
