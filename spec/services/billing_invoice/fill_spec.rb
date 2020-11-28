# frozen_string_literal: true

RSpec.describe BillingInvoice::Fill do
  subject do
    described_class.call(service_params)
  end

  shared_examples :does_not_fill_invoice do
    let(:service_error) { nil }

    it 'raises BillingInvoice::Fill::Error' do
      expect { subject }.to raise_error(BillingInvoice::Fill::Error, service_error)
    end

    it 'does not change invoice' do
      expect {
        begin
                 subject
        rescue StandardError
          nil
               end
      }.to_not change {
                 [invoice.reload.attributes, invoice.networks.count, invoice.destinations.count]
               }
    end

    it 'does not call BillingInvoice::GenerateDocument' do
      expect(BillingInvoice::GenerateDocument).to_not receive(:call)
    end
  end

  shared_examples :fills_invoice do
    it 'fills invoice' do
      subject
      expect(invoice.reload).to have_attributes(
                                    state_id: Billing::InvoiceState::PENDING,
                                    amount: 0,
                                    calls_count: 0,
                                    successful_calls_count: 0,
                                    calls_duration: 0,
                                    billing_duration: 0,
                                    first_call_at: nil,
                                    first_successful_call_at: nil,
                                    last_call_at: nil,
                                    last_successful_call_at: nil
                                  )
    end

    include_examples :changes_records_qty_of, Billing::InvoiceNetwork, by: 0
    include_examples :changes_records_qty_of, Billing::InvoiceDestination, by: 0
  end

  include_context :timezone_helpers

  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, account_attrs) }
  let(:account_attrs) { { contractor: contractor, timezone: account_timezone } }
  let(:account_timezone) { la_timezone }
  let(:account_time_zone) { account_timezone.time_zone }
  before { Billing::Invoice.where(account_id: account.id).delete_all }

  let!(:invoice) { FactoryBot.create(:invoice, invoice_attrs) }
  let(:invoice_attrs) do
    {
      account: account,
      vendor_invoice: true,
      type_id: Billing::InvoiceType::MANUAL,
      state_id: Billing::InvoiceState::NEW,
      start_date: account_time_zone.parse('2020-01-01 00:00:00'),
      end_date: account_time_zone.parse('2020-02-01 00:00:00')
    }
  end

  let(:service_params) { { invoice: invoice } }

  let(:stubs_generate_document) do
    expect(BillingInvoice::GenerateDocument).to receive(:call).with(service_params).once
  end

  context 'without data' do
    before { stubs_generate_document }

    include_examples :fills_invoice
  end

  context 'when invoice is pending' do
    let(:invoice_attrs) do
      super().merge state_id: Billing::InvoiceState::PENDING
    end

    include_examples :does_not_fill_invoice do
      let(:service_error) { 'invoice already filled' }
    end
  end

  context 'when invoice is approved' do
    let(:invoice_attrs) do
      super().merge state_id: Billing::InvoiceState::APPROVED
    end

    include_examples :does_not_fill_invoice do
      let(:service_error) { 'invoice already filled' }
    end
  end
end
