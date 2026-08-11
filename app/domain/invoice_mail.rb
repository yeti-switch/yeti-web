# frozen_string_literal: true

# The email that delivers an approved invoice: renders the system-wide
# Billing::InvoiceEmailTemplate against the invoice's data.
#
# Rendered once per invoice and shared by every recipient — the assigns
# deliberately say nothing about the individual contact, so one render serves
# the whole batch (as the single attachment row already does).
#
# Nothing here may raise. It runs between "invoice approved" and "email
# queued", so a template problem must cost the message its formatting, not its
# delivery: every failure falls back to the plain subject the code used before
# templates existed, and is captured for someone to fix.
class InvoiceMail
  class << self
    # The variable contract: what a template may reference, and what the admin
    # preview and save-time validation render against. Keep in step with
    # #assigns — a key here that #assigns omits will validate and then render
    # blank in production.
    def sample_assigns
      {
        account: {
          id: 123, name: 'Sample account', currency_id: 978, currency: 'EUR',
          balance: '1500.00', min_balance: '0.0', max_balance: '100000.0',
          invoice_period: 'Monthly'
        },
        contractor: { name: 'Sample contractor', address: '1 Example street', phones: '+11234567890' },
        invoice: sample_invoice,
        service_data: [{ service: 'Sample service', transactions_count: 3, amount: '30.00' }],
        document: { filename: 'invoice-1042.pdf' }
      }
    end

    # Flat name/example pairs for the "Available variables" admin panel.
    # Collections are listed by their group name only — a template iterates
    # them with {% for %}, so per-row keys are documented in the panel text.
    def variable_reference
      sample_assigns.flat_map do |group, values|
        next [{ name: group.to_s, example: "collection of #{values.first&.keys&.join(', ')}" }] if values.is_a?(Array)

        flatten_group(group, values)
      end
    end

    private

    def sample_invoice
      {
        id: 1042, reference: 'invoice-1042',
        created_at: '2026-08-01T00:00:00+00:00',
        start_date: '2026-07-01T00:00:00+00:00',
        end_date: '2026-08-01T00:00:00+00:00',
        amount_total: '1234.56', amount_spent: '1500.00', amount_earned: '265.44',
        originated: sample_leg, terminated: sample_leg,
        services: { amount_spent: '30.00', amount_earned: '0.0', transactions_count: 3 }
      }
    end

    def sample_leg
      {
        amount_spent: '750.00', amount_earned: '132.72',
        calls_count: 1000, successful_calls_count: 900,
        calls_duration: 54_000,
        first_call_at: '2026-07-01T00:01:00+00:00',
        last_call_at: '2026-07-31T23:59:00+00:00'
      }
    end

    def flatten_group(group, values)
      values.flat_map do |key, value|
        if value.is_a?(Hash)
          value.map { |sub, sub_value| { name: "#{group}.#{key}.#{sub}", example: sub_value.to_s } }
        else
          [{ name: "#{group}.#{key}", example: value.to_s }]
        end
      end
    end
  end

  # @param invoice_document [Billing::InvoiceDocument]
  def initialize(invoice_document)
    @invoice_document = invoice_document
  end

  def template
    @template ||= Billing::InvoiceEmailTemplate.instance
  end

  # @return [String] never blank — Log::EmailLog#subject is NOT NULL, and a
  #   template rendering to whitespace must not fail the insert.
  def subject
    rendered = render(:render_subject)
    rendered.presence || invoice.display_name
  end

  # @return [String,nil] nil renders the same placeholder body as before
  #   templates existed
  def html_body
    render(:render_html_body)
  end

  # @return [String,nil] nil keeps the message single-part, as it was before
  def text_body
    render(:render_text_body)
  end

  # The same vocabulary the PDF template sees, minus the per-destination and
  # per-network breakdowns (an email quotes totals), plus the name of the file
  # attached to this very message.
  def assigns
    @assigns ||= BillingInvoice::InvoiceData
                 .call(invoice: invoice, details: false)
                 .merge(document: { filename: "#{invoice_document.filename}.pdf" })
  end

  private

  attr_reader :invoice_document

  delegate :invoice, to: :invoice_document

  def render(method)
    return if template.nil?

    template.public_send(method, assigns)
  rescue StandardError => e
    CaptureError.capture(e, extra: { invoice_id: invoice.id, method: method })
    Rails.logger.error { "InvoiceMail##{method} for invoice #{invoice.id} failed: <#{e.class}>: #{e.message}" }
    nil
  end
end
