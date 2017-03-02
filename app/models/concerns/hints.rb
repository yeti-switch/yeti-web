module Hints
  extend ActiveSupport::Concern

    def send_to_hint
      System::SmtpConnection.exists? ? :nil : 'No available SMTP connection. Report will not be sent.'
    end

end