# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_templates
#
#  id         :integer(4)       not null, primary key
#  data       :binary
#  filename   :string           not null
#  name       :string           not null
#  sha1       :string
#  created_at :timestamptz
#
# Indexes
#
#  invoices_templates_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :invoice_template, class: Billing::InvoiceTemplate do
    sequence(:name) { |n| "invoice_template#{n}" }
    filename { 'filename.odt' }
  end
end
