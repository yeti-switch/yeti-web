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
      # Only senders that store a plain-text alternative produce a multipart
      # message; the rest stay single-part HTML exactly as before. Wire order
      # (text before html, so clients pick the richest part they understand) is
      # ActionMailer's parts_order, not this block's order.
      format.text { render plain: email_log.text_msg } if email_log.text_msg.present?
      # Some body is required even when the message is really just its
      # attachments, hence the blank placeholder.
      format.html { render html: email_log.msg&.html_safe || '  ' }
    end
  end
end
