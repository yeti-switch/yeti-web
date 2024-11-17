# frozen_string_literal: true

class Api::Rest::Admin::InvoicesController < Api::Rest::Admin::BaseController
  def pdf
    doc = ::Billing::InvoiceDocument.find_by(invoice_id: params[:id])
    return head 404 if doc.nil? || doc.pdf_data.blank?

    send_data doc.pdf_data, filename: "invoice-#{params[:id]}.pdf"
  end

  def odt
    doc = ::Billing::InvoiceDocument.find_by(invoice_id: params[:id])
    return head 404 if doc.nil? || doc.data.blank?

    send_data doc.pdf_data, filename: "invoice-#{params[:id]}.odt"
  end
end
