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

FactoryBot.define do
  factory :invoice_document, class: Billing::InvoiceDocument do
    invoice
    filename { 'fine.example' }
  end
end
