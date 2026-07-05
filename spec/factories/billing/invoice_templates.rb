# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_templates
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
FactoryBot.define do
  factory :invoice_template, class: 'Billing::InvoiceTemplate' do
    sequence(:name) { |n| "invoice_template#{n}" }
    html_template { '<html><body>{{ invoice.reference }}</body></html>' }
  end
end
