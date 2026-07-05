# frozen_string_literal: true

RSpec.describe 'Create new Invoice Template', type: :feature do
  include_context :login_as_admin

  before do
    visit new_invoice_template_path
  end

  include_context :fill_form, 'new_billing_invoice_template' do
    let(:html_template) { '<html><body>{{ invoice.reference }}</body></html>' }
    let(:attributes) do
      {
        name: 'new template',
        html_template: html_template
      }
    end

    it 'creates new invoice template succesfully' do
      click_on_submit
      expect(page).to have_css('.flash_notice', text: 'Invoice template was successfully created.')

      expect(Billing::InvoiceTemplate.last).to have_attributes(
        name: attributes[:name],
        html_template: html_template
      )
    end
  end
end
