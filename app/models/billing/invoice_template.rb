# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_templates
# Database name: primary
#
#  id                :integer(4)       not null, primary key
#  filename_template :string           default("invoice-{{invoice.reference}}"), not null
#  html_template     :text
#  name              :string           not null
#  created_at        :timestamptz
#
# Indexes
#
#  invoices_templates_name_key  (name) UNIQUE
#

class Billing::InvoiceTemplate < ApplicationRecord
  self.table_name = 'billing.invoice_templates'
  validates :name, presence: true, uniqueness: true
  validates :html_template, presence: true
  # NOT NULL alone would still allow '', which yeti-pdf treats as "no filename
  # template" and would leave the document with no name to store.
  validates :filename_template, presence: true, length: { maximum: 255 }

  def display_name
    name
  end
end
