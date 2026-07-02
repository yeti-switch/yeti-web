# frozen_string_literal: true

# Dispatcher that produces the invoice document. Chooses the renderer per
# template: when the account's template has an html_template AND the yeti-pdf
# service is configured (invoice.pdf_api), the HTML/yeti-pdf path is used;
# otherwise the legacy ODT (odf-report + pdf_converter) path.
module BillingInvoice
  class GenerateDocument < ApplicationService
    # PLACEHOLDERS
    # ACC_NAME,
    # ACC_BALANCE,
    # ACC_MIN_BALANCE,
    # ACC_MAX_BALANCE,
    # ACC_INV_PERIOD
    # CONTRACTOR_NAME,
    # CONTRACTOR_ADDRESS,
    # CONTRACTOR_PHONES,
    # INV_CREATED_AT,
    # INV_START_DATE,
    # INV_END_DATE,
    # INV_AMOUNT,
    # INV_CALLS_COUNT,
    # INV_FIRST_CALL_DATE,
    # INV_LAST_CALL_DATE
    # INV_DST_TABLE,
    # INV_DST_COUNTRY,
    # INV_DST_NETWORK,
    # INV_DST_RATE,
    # INV_DST_CALLS_COUNT,
    # INV_DST_CALLS_DURATION,
    # INV_DST_AMOUNT,
    # INV_DST_FIRST_CALL_AT,
    # INV_DST_LAST_CALL_AT
    # INV_REF

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

    # Scalar placeholders documented in the admin UI for ODT templates.
    def self.replaces_list
      %w[
        a_name
        a_balance
        a_balance_d
        a_min_balance
        a_min_balance_d
        a_max_balance
        a_max_balance_d
        a_inv_period

        c_name
        c_address
        c_phones

        i_id
        i_ref
        i_created_at
        i_start_date
        i_end_date

        i_total
        i_total_d
        i_spent
        i_spent_d
        i_earned
        i_earned_d

        i_orig_spent
        i_orig_earned
        i_orig_spent_d
        i_orig_earned_d

        i_orig_calls_count
        i_orig_successful_calls_count
        i_orig_calls_durationm
        i_orig_calls_duration_d
        i_orig_calls_duration
        i_orig_first_call_at
        i_orig_last_call_at

        i_term_spent
        i_term_earned
        i_term_spent_d
        i_term_earned_d

        i_term_calls_count
        i_term_successful_calls_count
        i_term_calls_durationm
        i_term_calls_duration_d
        i_term_calls_duration
        i_term_first_call_at
        i_term_last_call_at
      ]
    end

    parameter :invoice, required: true

    def call
      raise TemplateUndefined, invoice.id if template.blank?

      if use_pdf_api?
        RenderDocument::Html.call(invoice: invoice)
      elsif template.data.present?
        RenderDocument::Odt.call(invoice: invoice)
      elsif template.html_template.present?
        # An HTML template exists but yeti-pdf is not configured and there is no
        # ODT fallback — surface this clearly rather than failing deep in the
        # ODT path trying to write nil template bytes.
        raise PdfApiNotConfigured, invoice.id
      else
        raise TemplateUndefined, invoice.id
      end
    end

    private

    def template
      invoice.account.invoice_template
    end

    def use_pdf_api?
      template.html_template.present? && YetiPdf::Client.configured?
    end
  end
end
