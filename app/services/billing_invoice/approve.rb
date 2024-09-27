# frozen_string_literal: true

module BillingInvoice
  class Approve < ApplicationService
    parameter :invoice, required: true

    Error = Class.new(ApplicationService::Error)

    def call
      Billing::Invoice.transaction do
        raise_if_invalid!

        approve_invoice!
        send_email
      end
    end

    private

    def approve_invoice!
      invoice.update!(state_id: Billing::InvoiceState::APPROVED)
    rescue ActiveRecord::RecordInvalid => e
      raise Error, e.message
    end

    def send_email
      if invoice.invoice_document.present?
        invoice.invoice_document.send_invoice
      end
    end

    def raise_if_invalid!
      raise Error, 'Invoice already approved' if invoice.state_id == Billing::InvoiceState::APPROVED
      raise Error, "Invoice can't be approved" unless invoice.approvable?
    end
  end
end
