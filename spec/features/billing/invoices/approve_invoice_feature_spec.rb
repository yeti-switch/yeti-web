# frozen_string_literal: true

RSpec.describe 'Approve invoice feature', type: :feature do
  include_context :login_as_admin

  let(:approved_state_id) { Billing::InvoiceState::APPROVED }
  let!(:invoice) { FactoryBot.create(:invoice, :manual, :pending, :with_vendor_account) }

  context 'when valid data' do
    subject { click_action_item 'Approve' }

    before { visit invoice_path(invoice) }

    it 'should approve invoice', :js do
      subject

      expect(page).to have_flash_message 'Invoice was successful approved', type: :notice
      expect(invoice.reload).to have_attributes(state_id: approved_state_id)
    end
  end

  context 'when approve from batch action' do
    # The batch action declares `confirm:`. ActiveAdmin 3 rendered that as an
    # in-page modal with an OK button; ActiveAdmin 4 hands it to rails-ujs as
    # `data-confirm`, which is a native browser dialog.
    subject { accept_confirm { click_batch_action 'Approve Selected' } }

    before do
      visit invoices_path
      table_select_all
    end

    it 'should approve invoice', :js do
      subject

      expect(page).to have_flash_message 'Invoices are approved!', type: :notice
      expect(invoice.reload).to have_attributes(state_id: approved_state_id)
    end
  end

  context 'when invalid data', :js do
    subject { click_action_item 'Approve' }

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
