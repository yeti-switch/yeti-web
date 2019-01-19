# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_documents
#
#  id         :integer          not null, primary key
#  invoice_id :integer          not null
#  data       :binary
#  filename   :string           not null
#  pdf_data   :binary
#  csv_data   :binary
#  xls_data   :binary
#

class Billing::InvoiceDocument < Cdr::Base
  self.table_name = 'billing.invoice_documents'
  belongs_to :invoice

  # TODO: remove
  def self.get_file(invoice_id)
    Billing::InvoiceDocument.find(invoice_id).data
  end

  def contacts_for_invoices
    account.contacts_for_invoices
  end

  def attachments
    [
      # Notification::Attachment.new(filename: "#{filename}.csv", data: self.csv_data),
      Notification::Attachment.new(filename: "#{filename}.xls", data: xls_data),
      Notification::Attachment.new(filename: "#{filename}.pdf", data: pdf_data) # ,
      # Notification::Attachment.new(filename: "#{filename}.odt", data: self.data)
    ].reject { |a| a.data.blank? }
  end

  def subject
    invoice.display_name
  end

  def account
    invoice.account
  end

  # after_create do
  #   send_invoice
  # end

  def send_invoice
    contacts = contacts_for_invoices
    if contacts.any?
      # create attachments
      files = attachments
      files.map(&:save!)
      attachment_ids = files.map(&:id)
      contacts.each do |contact|
        Log::EmailLog.create!(
          contact_id: contact.id,
          smtp_connection_id: contact.smtp_connection.id,
          mail_to: contact.email,
          mail_from: contact.smtp_connection.from_address,
          subject: subject,
          attachment_id: attachment_ids
        )
      end
    end
  end
end
