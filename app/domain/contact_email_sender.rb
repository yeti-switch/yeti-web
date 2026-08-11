# frozen_string_literal: true

class ContactEmailSender
  class << self
    # @param contacts [Array<Billing::Contact>]
    # @param subject [String]
    # @param message [String,nil] HTML body
    # @param text_message [String,nil] plain-text alternative; supplying it makes
    #   the email multipart, omitting it keeps it single-part HTML as before
    # @param attachments [Array<Notification::Attachment,nil]
    def batch_send_emails(contacts, subject:, message: nil, text_message: nil, attachments: nil)
      ApplicationRecord.transaction do
        contacts.uniq.map do |contact|
          new(contact).send_email(
            subject: subject,
            message: message,
            text_message: text_message,
            attachments: attachments
          )
        end
      end
    end
  end

  # @param contact [Billing::Contact]
  def initialize(contact)
    @contact = contact
  end

  # @param subject [String]
  # @param message [String,nil] HTML body
  # @param text_message [String,nil] plain-text alternative
  # @param attachments [Array<Notification::Attachment,nil]
  def send_email(subject:, message: nil, text_message: nil, attachments: nil)
    return if contact.smtp_connection.nil?

    ApplicationRecord.transaction do
      email_log = create_email_log(
        subject: subject,
        message: message,
        text_message: text_message,
        attachments: attachments
      )
      Worker::SendEmailLogJob.perform_later(email_log.id)
      email_log
    end
  end

  private

  attr_reader :contact

  def create_email_log(subject:, message:, text_message:, attachments:)
    Log::EmailLog.create!(
      contact: contact,
      smtp_connection: contact.smtp_connection,
      mail_to: contact.email,
      mail_from: contact.smtp_connection.from_address,
      subject: subject,
      msg: message.presence,
      text_msg: text_message.presence,
      attachment_id: attachments.presence&.map(&:id).presence
    )
  end
end
