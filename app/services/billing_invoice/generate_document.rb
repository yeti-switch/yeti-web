# frozen_string_literal: true

# Generates the invoice PDF document: builds the raw invoice data payload, sends
# it with the account's html_template to the external yeti-pdf service, and
# stores the returned PDF on the InvoiceDocument.
#
# Any generation failure (no template, yeti-pdf not configured, yeti-pdf error)
# is recorded on invoice.pdf_error and swallowed, so a rendering problem never
# aborts invoice creation — it surfaces in the UI and the document can be
# regenerated later. A successful run clears a previously recorded error.
module BillingInvoice
  class GenerateDocument < ApplicationService
    class TemplateUndefined < Error
      def initialize(invoice_id)
        super("Template blank for invoice: #{invoice_id}")
      end
    end

    class PdfApiNotConfigured < Error
      def initialize(invoice_id)
        super("Template for invoice #{invoice_id} has an html_template but invoice.pdf_api is not configured")
      end
    end

    parameter :invoice, required: true

    def call
      generate_document!
      invoice.update_column(:pdf_error, nil) if invoice.pdf_error.present?
    rescue Error, YetiPdf::Client::Error => e
      invoice.update_column(:pdf_error, e.message)
      logger.warn { "invoice ##{invoice.id} document generation failed: #{e.class}: #{e.message}" }
    end

    private

    def generate_document!
      raise TemplateUndefined, invoice.id if template.blank? || template.html_template.blank?
      raise PdfApiNotConfigured, invoice.id unless YetiPdf::Client.configured?

      data = InvoiceData.call(invoice: invoice)
      pdf_data = YetiPdf::Client.render_pdf(template: template.html_template, data: data)

      Billing::InvoiceDocument.create!(
        invoice: invoice,
        filename: invoice.file_name.to_s,
        pdf_data: pdf_data
      )
    end

    def template
      invoice.account.invoice_template
    end
  end
end
