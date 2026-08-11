# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_email_templates
# Database name: primary
#
#  id        :integer(2)       default(1), not null, primary key
#  html_body :text             not null
#  subject   :string           not null
#  text_body :text             not null
#

# The email that carries an approved invoice to the account's contacts, as an
# editable liquid template. System-wide — a single row, guaranteed by a CHECK
# constraint and seeded by the migration, so there is nothing to choose per
# account and #instance never has to cope with more than one.
#
# Rendered against the same data the PDF template gets (BillingInvoice::
# InvoiceData without the per-destination detail), plus a `document` group
# naming the attachment; see InvoiceMail.
class Billing::InvoiceEmailTemplate < ApplicationRecord
  self.table_name = 'billing.invoice_email_templates'

  include WithPaperTrail
  include LiquidTemplate

  validates :subject, :html_body, :text_body, presence: true
  validates :subject, length: { maximum: 255 }
  validates_liquid_syntax :subject, :html_body, :text_body, sample: -> { InvoiceMail.sample_assigns }

  # There is no packaged fallback for the bodies, so the row must survive.
  before_destroy { throw :abort }

  # The row is created by the migration, so a nil here means a broken install
  # rather than "not configured yet" — InvoiceMail treats it as such and falls
  # back rather than raising in the middle of a delivery.
  def self.instance
    first
  end

  def display_name
    'Invoice email template'
  end

  def render_subject(assigns)
    render_liquid(subject, assigns).strip
  end

  def render_html_body(assigns)
    render_liquid(html_body, assigns)
  end

  def render_text_body(assigns)
    render_liquid(text_body, assigns)
  end
end
