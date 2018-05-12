# == Schema Information
#
# Table name: notifications.email_logs
#
#  id                 :integer          not null, primary key
#  batch_id           :integer
#  created_at         :datetime
#  sent_at            :datetime
#  contact_id         :integer
#  smtp_connection_id :integer
#  mail_to            :string           not null
#  mail_from          :string           not null
#  subject            :string           not null
#  msg                :string
#  error              :string
#  attachment_id      :integer          is an Array
#

class Log::EmailLog < Yeti::ActiveRecord
  self.table_name = 'notifications.email_logs'
  belongs_to :contact, class_name: 'Billing::Contact', foreign_key: :contact_id
  belongs_to :smtp_connection, class_name: 'System::SmtpConnection', foreign_key: :smtp_connection_id
  #belongs_to :attachment, class_name: Notification::Attachment
  #belongs_to :attachment_no_data, -> { select [:id, :filename ] },
  #           class_name: Notification::Attachment, foreign_key: :attachment_id



  def attachments
    @attachments ||= Notification::Attachment.where(id: attachment_id)
  end

  def getfile(id)
    attachments.where("id=?", id).take
  end

  def attachments_no_data
    @attachments_no_data ||= Notification::Attachment.select(:id, :filename).where(id: attachment_id)
  end

  after_create do
    self.class.delay.send_email(self.id)
  end

  def self.send_email(id)
    begin
      YetiMail.email_message(id).deliver!
      Log::EmailLog.where(id: id).update_all(sent_at: Time.now)
    rescue StandardError => e
      Rails.logger.warn { e.message }
      Rails.logger.warn { e.backtrace.join("\n") }

      Log::EmailLog.where(id: id).update_all(error: e.message)
    end
  end


end

