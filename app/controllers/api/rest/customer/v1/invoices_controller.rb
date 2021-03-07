# frozen_string_literal: true

class Api::Rest::Customer::V1::InvoicesController < Api::Rest::Customer::V1::BaseController
  before_action :find_invoice, only: :download

  def download
    doc = @invoice.invoice_document

    if doc&.pdf_data.present?
      send_data doc.pdf_data, type: 'application/pdf', filename: "#{doc.filename}.pdf"
    else
      head 404
    end
  rescue StandardError => e
    handle_exceptions(e)
  end

  private

  def find_invoice
    resource_klass = Api::Rest::Customer::V1::InvoiceResource
    key = resource_klass.verify_key(params[:id], context)
    @invoice = resource_klass.find_by_key(key, context: context)._model
  rescue StandardError => e
    handle_exceptions(e)
  end
end
