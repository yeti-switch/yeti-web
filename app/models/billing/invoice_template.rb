# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_templates
# Database name: primary
#
#  id            :integer(4)       not null, primary key
#  html_template :text
#  name          :string           not null
#  created_at    :timestamptz
#
# Indexes
#
#  invoices_templates_name_key  (name) UNIQUE
#

class Billing::InvoiceTemplate < ApplicationRecord
  self.table_name = 'billing.invoice_templates'
  validates :name, presence: true, uniqueness: true
  validates :html_template, presence: true

  def display_name
    name
  end
end
