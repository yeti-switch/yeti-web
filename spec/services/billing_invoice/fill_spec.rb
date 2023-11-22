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
      expect { safe_subject }.to_not change {
        [
          invoice.reload.attributes,
          invoice.originated_networks.count,
          invoice.terminated_networks.count,
          invoice.originated_destinations.count,
          invoice.terminated_destinations.count
        ]
      }
    end

    it 'does not call BillingInvoice::GenerateDocument' do
      expect(BillingInvoice::GenerateDocument).to_not receive(:call)
      safe_subject
    end
  end

  shared_examples :fills_invoice do
    it 'fills invoice' do
      subject
      expect(invoice.reload).to have_attributes(
                                    state_id: Billing::InvoiceState::PENDING,
                                    originated_amount: 0,
                                    originated_calls_count: 0,
                                    originated_successful_calls_count: 0,
                                    originated_calls_duration: 0,
                                    originated_billing_duration: 0,
                                    first_originated_call_at: nil,
                                    last_originated_call_at: nil,
                                    terminated_amount: 0,
                                    terminated_calls_count: 0,
                                    terminated_successful_calls_count: 0,
                                    terminated_calls_duration: 0,
                                    terminated_billing_duration: 0,
                                    first_terminated_call_at: nil,
                                    last_terminated_call_at: nil
                                  )
    end

    include_examples :changes_records_qty_of, Billing::InvoiceOriginatedNetwork, by: 0
    include_examples :changes_records_qty_of, Billing::InvoiceTerminatedNetwork, by: 0
    include_examples :changes_records_qty_of, Billing::InvoiceOriginatedDestination, by: 0
    include_examples :changes_records_qty_of, Billing::InvoiceTerminatedDestination, by: 0
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
