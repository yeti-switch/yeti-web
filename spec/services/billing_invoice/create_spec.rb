# frozen_string_literal: true

RSpec.describe BillingInvoice::Create do
  subject do
    described_class.call(service_params)
  end

  shared_examples :creates_an_invoice do
    it 'creates an invoice with correct params' do
      expect { subject }.to change { Billing::Invoice.count }.by(1)
      invoice = Billing::Invoice.last!

      expect(invoice).to have_attributes(
                             contractor_id: account.contractor_id,
                             account_id: account.id,
                             start_date: service_params[:start_time],
                             end_date: service_params[:end_time],
                             vendor_invoice: service_params[:is_vendor],
                             type_id: service_params[:type_id],
                             state_id: Billing::InvoiceState::NEW,
                             amount: 0,
                             billing_duration: 0,
                             calls_count: 0,
                             calls_duration: 0,
                             first_call_at: nil,
                             first_successful_call_at: nil,
                             last_call_at: nil,
                             last_successful_call_at: nil,
                             successful_calls_count: nil
                           )
    end
  end

  include_context :timezone_helpers
  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, account_attrs) }
  let(:account_attrs) { { contractor: contractor, timezone: account_timezone } }
  let(:account_timezone) { la_timezone }
  let(:account_time_zone) { account_timezone.time_zone }
  let(:service_params) do
    {
      account: account,
      is_vendor: true,
      start_time: account_time_zone.parse('2020-01-01'),
      end_time: account_time_zone.parse('2020-02-01'),
      type_id: Billing::InvoiceType::MANUAL
    }
  end

  context 'when type_id MANUAL' do
    include_examples :creates_an_invoice
  end

  context 'when type_id AUTO_FULL' do
    let(:service_params) { super().merge type_id: Billing::InvoiceType::AUTO_FULL }

    include_examples :creates_an_invoice
  end

  context 'when type_id AUTO_PARTIAL' do
    let(:service_params) { super().merge type_id: Billing::InvoiceType::AUTO_PARTIAL }

    include_examples :creates_an_invoice
  end
end
