# frozen_string_literal: true

RSpec.describe 'Change invoice reference feature', type: :feature do
  include_context :login_as_admin

  let!(:invoice) { FactoryBot.create(:invoice, :manual, :pending, :with_vendor_account, reference: 'old-reference') }

  context 'when pending invoice' do
    before do
      # avoid real PDF rendering; assert the regenerate call instead
      allow(BillingInvoice::GenerateDocument).to receive(:call)
      visit invoice_path(invoice)
    end

    it 'offers the Change Reference action' do
      expect(page).to have_link('Change Reference')
    end

    it 'updates the reference and regenerates the pdf by default', :js do
      click_link 'Change Reference'
      within '.ui-dialog' do
        expect(find_field('reference').value).to eq('old-reference')
        expect(find_field('regenerate_pdf')).to be_checked
        fill_in 'reference', with: 'new-reference'
        click_button 'OK'
      end

      expect(page).to have_flash_message 'Invoice reference was updated', type: :notice
      expect(invoice.reload).to have_attributes(reference: 'new-reference')
      expect(BillingInvoice::GenerateDocument).to have_received(:call).with(invoice: an_instance_of(Billing::Invoice))
    end

    it 'skips pdf regeneration when the flag is unchecked', :js do
      click_link 'Change Reference'
      within '.ui-dialog' do
        fill_in 'reference', with: 'new-reference'
        uncheck 'regenerate_pdf'
        click_button 'OK'
      end

      expect(page).to have_flash_message 'Invoice reference was updated', type: :notice
      expect(invoice.reload).to have_attributes(reference: 'new-reference')
      expect(BillingInvoice::GenerateDocument).to_not have_received(:call)
    end
  end

  context 'when approved invoice' do
    let!(:invoice) { FactoryBot.create(:invoice, :manual, :approved, :with_vendor_account, reference: 'old-reference') }

    before { visit invoice_path(invoice) }

    it 'does not offer the Change Reference action' do
      expect(page).to_not have_link('Change Reference')
    end
  end
end
