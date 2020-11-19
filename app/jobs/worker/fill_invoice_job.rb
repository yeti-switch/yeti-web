# frozen_string_literal: true

module Worker
  class FillInvoiceJob < ::ApplicationJob
    queue_as 'invoice'

    def perform(invoice_id)
      invoice = Billing::Invoice.find_by(id: invoice_id)
      return if invoice.nil?

      BillingInvoice::Fill.call(invoice: invoice)
    end
  end
end
