# frozen_string_literal: true

class ContactEmailSender
  class << self
    # @param contacts [Array<Billing::Contact>]
    # @param subject [String]
    # @param message [String,nil]
    # @param attachments [Array<Notification::Attachment,nil]
    def batch_send_emails(contacts, subject:, message: nil, attachments: nil)
      ApplicationRecord.transaction do
        contacts.uniq.map do |contact|
          new(contact).send_email(subject: subject, message: message, attachments: attachments)
        end
      end
    end
  end

  # @param contact [Billing::Contact]
  def initialize(contact)
    @contact = contact
  end

  # @param subject [String]
  # @param message [String,nil]
  # @param attachments [Array<Notification::Attachment,nil]
  def send_email(subject:, message: nil, attachments: nil)
    ApplicationRecord.transaction do
      email_log = create_email_log(
        subject: subject,
        message: message,
        attachments: attachments
      )
      Worker::SendEmailLogJob.perform_later(email_log.id)
      email_log
    end
  end

  private

  attr_reader :contact

  def create_email_log(subject:, message:, attachments:)
    Log::EmailLog.create!(
      contact: contact,
      smtp_connection: contact.smtp_connection,
      mail_to: contact.email,
      mail_from: contact.smtp_connection.from_address,
      subject: subject,
      msg: message.presence,
      attachment_id: attachments.presence&.map(&:id).presence
    )
  end
end
