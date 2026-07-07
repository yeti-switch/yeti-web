# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_documents
# Database name: cdr
#
#  id         :integer(4)       not null, primary key
#  filename   :string           not null
#  pdf_data   :binary
#  invoice_id :integer(4)       not null
#
# Indexes
#
#  invoice_documents_invoice_id_idx  (invoice_id) UNIQUE
#
# Foreign Keys
#
#  invoice_documents_invoice_id_fkey  (invoice_id => invoices.id)
#

class Billing::InvoiceDocument < Cdr::Base
  self.table_name = 'billing.invoice_documents'
  belongs_to :invoice

  delegate :contacts_for_invoices, to: :account

  def attachments
    [
      Notification::Attachment.new(filename: "#{filename}.pdf", data: pdf_data)
    ].reject { |a| a.data.blank? }
  end

  def subject
    invoice.display_name
  end

  delegate :account, to: :invoice

  # after_create do
  #   send_invoice
  # end

  def send_invoice
    contacts = contacts_for_invoices
    return if contacts.empty?

    # create attachments
    files = attachments
    files.each(&:save!)
    ContactEmailSender.batch_send_emails(
      contacts,
      subject: subject,
      attachments: files
    )
  end
end
