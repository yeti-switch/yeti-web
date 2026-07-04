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
RSpec.describe Billing::InvoiceTemplate do
  it 'is valid with a name and an html_template' do
    template = described_class.new(name: 'html-one', html_template: '<p>{{ invoice.reference }}</p>')
    expect(template).to be_valid
  end

  it 'is invalid without an html_template' do
    template = described_class.new(name: 'empty')
    expect(template).not_to be_valid
    expect(template.errors[:html_template]).to be_present
  end

  it 'is invalid without a name' do
    template = described_class.new(html_template: '<p>x</p>')
    expect(template).not_to be_valid
    expect(template.errors[:name]).to be_present
  end
end
