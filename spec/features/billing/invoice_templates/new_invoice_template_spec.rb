# frozen_string_literal: true

require 'spec_helper'

file_path = "#{Rails.root}/spec/features/billing/invoice_templates/template.odt"

describe 'Create new Invoice Template', type: :feature do
  include_context :login_as_admin

  before do
    visit new_invoice_template_path
  end

  include_context :fill_form, 'new_billing_invoice_template' do
    let(:attributes) do
      {
        name: 'new template',
        template_file: file_path
      }
    end

    it 'creates new invoice template succesfully' do
      click_on_submit
      expect(page).to have_css('.flash_notice', text: 'Invoice template was successfully created.')

      expect(Billing::InvoiceTemplate.last).to have_attributes(
        name: attributes[:name],
        filename: File.basename(file_path),
        data: File.read(file_path).b,
        sha1: Digest::SHA1.file(file_path).to_s
      )
    end
  end
end
