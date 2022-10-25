# frozen_string_literal: true

class YetiMail < ActionMailer::Base
  def email_message(email_log)
    if email_log.attachments.present?
      email_log.attachments.each do |a|
        attachments[File.basename(a.filename)] = { content: a.data }
      end
    end

    mail(
      to: email_log.mail_to,
      subject: email_log.subject,
      from: email_log.mail_from,
      delivery_method_options: email_log.smtp_connection.delivery_options
    ) do |format|
      format.html { render html: email_log.msg&.html_safe || '  ' }
    end
  end
end
