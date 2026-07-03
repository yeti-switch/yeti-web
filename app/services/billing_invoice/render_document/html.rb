# frozen_string_literal: true

module BillingInvoice
  module RenderDocument
    # HTML renderer: builds the raw invoice data payload, sends it with the
    # account's html_template to the external yeti-pdf service, and stores the
    # returned PDF (plus the merged HTML for debugging) on the InvoiceDocument.
    class Html < ApplicationService
      parameter :invoice, required: true

      def call
        data = InvoiceData.call(invoice: invoice)
        template = invoice.account.invoice_template.html_template

        pdf_data = YetiPdf::Client.render_pdf(template: template, data: data)

        Billing::InvoiceDocument.create!(
          invoice: invoice,
          filename: invoice.file_name.to_s,
          data: merged_html(template, data),
          pdf_data: pdf_data
        )
      end

      private

      # Merged HTML kept only for debugging/preview. The /v1/render/html endpoint
      # is a cheap pongo2 merge (no PDF), so this is a lightweight extra call; a
      # failure here must not fail the invoice, so it degrades to nil.
      def merged_html(template, data)
        YetiPdf::Client.render_html(template: template, data: data)
      rescue YetiPdf::Client::Error => e
        logger.warn { "yeti-pdf merged-HTML fetch failed for invoice #{invoice.id}: #{e.message}" }
        nil
      end
    end
  end
end
