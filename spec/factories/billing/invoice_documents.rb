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

FactoryBot.define do
  factory :invoice_document, class: 'Billing::InvoiceDocument' do
    invoice
    filename { 'fine.example' }

    trait :filled do
      pdf_data { 'pdf_data' }
    end
  end
end
