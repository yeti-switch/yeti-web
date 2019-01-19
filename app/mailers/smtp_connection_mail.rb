# frozen_string_literal: true

class SmtpConnectionMail < ActionMailer::Base
  def test_message(smtp_connection, attrs = {})
    mail(to: attrs.fetch(:to),
         subject: attrs.fetch(:subject),
         body: attrs.fetch(:body),
         content_type: 'text/html',
         from: smtp_connection.from,
         delivery_method_options: smtp_connection.delivery_options)
  end
end
