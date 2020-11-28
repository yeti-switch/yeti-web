# frozen_string_literal: true

RSpec.describe 'New Invoice', type: :feature, js: true do
  subject do
    click_submit('Create Invoice')
  end

  shared_examples :creates_an_invoice do |is_vendor:|
    # let(:expected_start_time) {}
    # let(:expected_end_time) {}

    it 'creates an invoice' do
      expect(BillingInvoice::Create).to receive(:call).with(
          account: account,
          is_vendor: is_vendor,
          start_time: expected_start_time,
          end_time: expected_end_time,
          type_id: Billing::InvoiceType::MANUAL
        ).once.and_call_original

      expect { subject }.to change { Billing::Invoice.count }.by(1)
      expect(page).to have_flash_message('Invoice was successfully created.', type: :notice, exact: true)
    end
  end

  include_context :timezone_helpers
  include_context :login_as_admin
  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, account_attrs) }
  let(:account_attrs) { { contractor: contractor } }
  let(:before_visit!) {}
  before do
    before_visit!
    visit new_invoice_path
  end

  context 'without filled inputs' do
    it 'does not create an invoice' do
      expect {
        subject
        expect(page).to have_semantic_errors(count: 3)
      }.to_not change { Billing::Invoice.count }

      expect(page).to have_semantic_error("Account can't be blank")
      expect(page).to have_semantic_error("Start time can't be blank")
      expect(page).to have_semantic_error("End time can't be blank")
    end
  end

  context 'with vendor account' do
    before do
      within_form_for do
        fill_in_chosen 'Vendor invoice', with: 'Yes'
        fill_in_chosen 'Contractor', with: contractor.display_name, ajax: true
        fill_in_chosen 'Account', with: account.display_name, ajax: true
        fill_in 'Start date', with: '2020-01-01'
        fill_in 'End date', with: '2020-02-01'
      end
    end

    include_examples :creates_an_invoice, is_vendor: true do
      let(:expected_start_time) { utc_timezone.time_zone.parse('2020-01-01') }
      let(:expected_end_time) { utc_timezone.time_zone.parse('2020-02-01') }
    end

    context 'when account in LA timezone' do
      let(:account_attrs) { super().merge timezone: la_timezone }

      include_examples :creates_an_invoice, is_vendor: true do
        let(:expected_start_time) { la_timezone.time_zone.parse('2020-01-01') }
        let(:expected_end_time) { la_timezone.time_zone.parse('2020-02-01') }
      end
    end
  end

  context 'with customer account' do
    before do
      within_form_for do
        fill_in_chosen 'Contractor', with: contractor.display_name, ajax: true
        fill_in_chosen 'Account', with: account.display_name, ajax: true
        fill_in 'Start date', with: '2020-01-01'
        fill_in 'End date', with: '2020-02-01'
      end
    end

    include_examples :creates_an_invoice, is_vendor: false do
      let(:expected_start_time) { utc_timezone.time_zone.parse('2020-01-01') }
      let(:expected_end_time) { utc_timezone.time_zone.parse('2020-02-01') }
    end

    context 'when account in LA timezone' do
      let(:account_attrs) { super().merge timezone: la_timezone }

      include_examples :creates_an_invoice, is_vendor: false do
        let(:expected_start_time) { la_timezone.time_zone.parse('2020-01-01') }
        let(:expected_end_time) { la_timezone.time_zone.parse('2020-02-01') }
      end
    end
  end
end
