# frozen_string_literal: true

RSpec.describe 'New Invoice', type: :feature, js: true do
  subject do
    visit new_invoice_path
    fill_form!
    click_submit('Create Invoice')
  end

  shared_examples :creates_an_invoice do
    # let(:expected_start_time) {}
    # let(:expected_end_time) {}

    it 'creates an invoice' do
      expect(BillingInvoice::Create).to receive(:call).with(
          account: account,
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

  let(:fill_form!) do
    within_form_for do
      fill_in_tom_select 'Contractor', with: contractor.display_name, ajax: true
      fill_in_tom_select 'Account', with: account.display_name, ajax: true
      fill_in 'Start date', with: '2020-01-01'
      fill_in 'End date', with: '2020-02-01'
    end
  end

  include_examples :creates_an_invoice do
    let(:expected_start_time) { ActiveSupport::TimeZone.new(utc_timezone).parse('2020-01-01') }
    let(:expected_end_time) { ActiveSupport::TimeZone.new(utc_timezone).parse('2020-02-01') }
  end

  context 'when account in LA timezone' do
    let(:account_attrs) { super().merge timezone: la_timezone }

    include_examples :creates_an_invoice do
      let(:expected_start_time) { ActiveSupport::TimeZone.new(la_timezone).parse('2020-01-01') }
      let(:expected_end_time) { ActiveSupport::TimeZone.new(la_timezone).parse('2020-02-01') }
    end
  end

  context 'without filled inputs' do
    let(:fill_form!) { nil }

    it 'does not create an invoice' do
      expect {
        subject
        expect(page).to have_semantic_errors(count: 3)
      }.to_not change { Billing::Invoice.count }

      expect(page).to have_semantic_error("Account can't be blank")
      expect(page).to have_semantic_error("Start date can't be blank")
      expect(page).to have_semantic_error("End date can't be blank")
    end
  end
end
