# frozen_string_literal: true

RSpec.describe 'Approve invoide feature', type: :feature do
  subject { click_action_item 'Approve' }

  include_context :login_as_admin

  context 'when valid data' do
    let!(:invoice) { FactoryBot.create(:invoice, :manual, :pending, :with_vendor_account) }
    let(:approved_state_id) { Billing::InvoiceState::APPROVED }

    before { visit invoice_path(invoice) }

    it 'should approve invoice', :js do
      subject

      expect(page).to have_flash_message 'Invoice was successful approved', type: :notice
      expect(invoice.reload).to have_attributes(state_id: approved_state_id)
    end
  end

  context 'when invalid data', :js do
    let!(:invoice) { FactoryBot.create(:invoice, :pending, :with_vendor_account) }

    before do
      allow(BillingInvoice::Approve).to receive(:call).and_raise(BillingInvoice::Approve::Error, 'error')
      visit invoice_path(invoice)
    end

    it 'should render error' do
      subject

      expect(page).to have_flash_message 'error', type: :error
      expect(BillingInvoice::Approve).to have_received(:call)
    end
  end
end
