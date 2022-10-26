# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.email_logs
#
#  id                 :bigint(8)        not null, primary key
#  error              :string
#  mail_from          :string           not null
#  mail_to            :string           not null
#  msg                :string
#  sent_at            :datetime
#  subject            :string           not null
#  created_at         :datetime
#  attachment_id      :integer(4)       is an Array
#  batch_id           :bigint(8)
#  contact_id         :integer(4)
#  smtp_connection_id :integer(4)
#

class Log::EmailLog < ApplicationRecord
  self.table_name = 'notifications.email_logs'
  belongs_to :contact, class_name: 'Billing::Contact', foreign_key: :contact_id, optional: true
  belongs_to :smtp_connection, class_name: 'System::SmtpConnection', foreign_key: :smtp_connection_id, optional: true
  # belongs_to :attachment, class_name: Notification::Attachment
  # belongs_to :attachment_no_data, -> { select [:id, :filename ] },
  #           class_name: Notification::Attachment, foreign_key: :attachment_id

  def attachments
    @attachments ||= Notification::Attachment.where(id: attachment_id)
  end

  def getfile(id)
    attachments.find_by(id: id)
  end

  def attachments_no_data
    @attachments_no_data ||= Notification::Attachment.select(:id, :filename).where(id: attachment_id)
  end
end
