# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_templates
#
#  id            :integer(4)       not null, primary key
#  data          :binary
#  filename      :string
#  html_template :text
#  name          :string           not null
#  sha1          :string
#  created_at    :timestamptz
#
# Indexes
#
#  invoices_templates_name_key  (name) UNIQUE
#
RSpec.describe Billing::InvoiceTemplate do
  it 'is valid with an ODT file (data + .odt filename)' do
    template = described_class.new(name: 'odt-one', filename: 'x.odt', data: 'binary')
    expect(template).to be_valid
  end

  it 'is valid with only an html_template (no file)' do
    template = described_class.new(name: 'html-one', html_template: '<p>{{ invoice.reference }}</p>')
    expect(template).to be_valid
  end

  it 'is invalid with neither data nor html_template' do
    template = described_class.new(name: 'empty')
    expect(template).not_to be_valid
    expect(template.errors[:base]).to be_present
  end

  it 'rejects a non-.odt filename' do
    template = described_class.new(name: 'bad', filename: 'x.txt', data: 'binary')
    expect(template).not_to be_valid
    expect(template.errors[:filename]).to be_present
  end

  it 'sets sha1 from the html_template' do
    template = described_class.new(name: 'html-sha', html_template: '<p>hi</p>')
    template.valid?
    expect(template.sha1).to eq(Digest::SHA1.hexdigest('<p>hi</p>'))
  end
end
