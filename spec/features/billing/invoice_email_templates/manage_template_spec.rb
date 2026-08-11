# frozen_string_literal: true

RSpec.describe 'Manage the invoice email template' do
  include_context :login_as_admin

  let(:template) { Billing::InvoiceEmailTemplate.instance }

  describe 'index' do
    before { visit invoice_email_templates_path }

    it 'goes straight to the single row, since there is nothing to list' do
      expect(page).to have_current_path(invoice_email_template_path(1))
    end

    it 'offers no way to create one' do
      expect(page).not_to have_link('New Invoice email template')
    end
  end

  describe 'show' do
    before { visit invoice_email_template_path(template) }

    it 'documents the variables available to the template' do
      expect(page).to have_content('invoice.reference')
      expect(page).to have_content('document.filename')
    end

    it 'shows both parts, because an email that reads badly in plain text is half broken' do
      expect(page).to have_content('Plain text body')
      expect(page).to have_content('HTML body')
    end

    it 'offers no delete action' do
      expect(page).not_to have_link('Delete')
    end
  end

  describe 'edit' do
    before { visit edit_invoice_email_template_path(template) }

    it 'saves a valid template' do
      fill_in 'billing_invoice_email_template[text_body]', with: 'Invoice {{ invoice.reference }}'
      click_button 'Update Invoice email template'

      expect(template.reload.text_body).to eq('Invoice {{ invoice.reference }}')
    end

    it 'rejects a template referencing an unavailable variable' do
      original = template.html_body
      fill_in 'billing_invoice_email_template[html_body]', with: '{{ invoice.secret_column }}'
      click_button 'Update Invoice email template'

      expect(page).to have_content('unknown variable')
      expect(template.reload.html_body).to eq(original)
    end
  end

  describe 'preview' do
    it 'renders both parts against sample data, the HTML inside a sandboxed frame' do
      visit preview_invoice_email_template_path(template)

      expect(page.first('iframe')['sandbox']).to eq('')
      expect(page.body).to include('Plain text part')
      expect(page.body).to include('HTML part')
      expect(page.body).to include('invoice-1042')
    end

    context 'when the stored template contains script' do
      before do
        template.update_column(:html_body, '<p>hi</p><script>alert(1)</script>')
        visit preview_invoice_email_template_path(template)
      end

      it 'escapes the body into srcdoc rather than the page DOM' do
        expect(page.first('iframe')['sandbox']).to eq('')
        expect(page.body).to include('srcdoc=')
        expect(page.body).not_to include('<script>alert(1)</script>')
      end
    end

    context 'when the stored template cannot render' do
      before do
        template.update_column(:text_body, '{{ invoice.nope }}')
        visit preview_invoice_email_template_path(template)
      end

      # An unknown variable degrades to a blank at render time rather than
      # raising, so the preview still renders — that is the point of the
      # lenient render path.
      it 'still shows the preview' do
        expect(page.body).to include('Plain text part')
      end
    end
  end
end
