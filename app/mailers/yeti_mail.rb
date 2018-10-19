class YetiMail < ActionMailer::Base
  def email_message(log_id)
    log = Log::EmailLog.find(log_id)
    if log.attachments.present?
      log.attachments.each  do |a|
          attachments[File.basename(a.filename)] = {content: a.data }
      end
    end

    mail(to: log.mail_to,
         subject: log.subject,
         from: log.mail_from,
         delivery_method_options: log.smtp_connection.delivery_options
    ) do |format|
      format.html { render html: log.msg.try!(:html_safe) || '  ' }
    end
  end


end
