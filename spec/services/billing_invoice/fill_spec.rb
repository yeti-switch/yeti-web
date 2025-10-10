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
          Billing::InvoiceOriginatedNetwork.count,
          Billing::InvoiceTerminatedNetwork.count,
          Billing::InvoiceOriginatedDestination.count,
          Billing::InvoiceTerminatedDestination.count,
          Billing::InvoiceServiceData.count
        ]
      }
    end

    it 'does not call BillingInvoice::GenerateDocument' do
      expect(BillingInvoice::GenerateDocument).to_not receive(:call)
      safe_subject
    end
  end

  shared_examples :fills_invoice do
    let(:expected_invoice_orig_net_qty) { 0 }
    let(:expected_invoice_term_net_qty) { 0 }
    let(:expected_invoice_orig_dst_qty) { 0 }
    let(:expected_invoice_term_dst_qty) { 0 }
    let(:expected_srv_data_qty) { 0 }
    let(:expected_invoice_attrs) { {} }
    it 'fills invoice' do
      subject
      expect(invoice.reload).to have_attributes(
                                    state_id: Billing::InvoiceState::PENDING,
                                    amount_total: 0,
                                    amount_spent: 0,
                                    amount_earned: 0,
                                    originated_amount_spent: 0,
                                    originated_amount_earned: 0,
                                    originated_calls_count: 0,
                                    originated_successful_calls_count: 0,
                                    originated_calls_duration: 0,
                                    originated_billing_duration: 0,
                                    first_originated_call_at: nil,
                                    last_originated_call_at: nil,
                                    terminated_amount_spent: 0,
                                    terminated_amount_earned: 0,
                                    terminated_calls_count: 0,
                                    terminated_successful_calls_count: 0,
                                    terminated_calls_duration: 0,
                                    terminated_billing_duration: 0,
                                    first_terminated_call_at: nil,
                                    last_terminated_call_at: nil,
                                    services_amount_spent: 0,
                                    services_amount_earned: 0,
                                    service_transactions_count: 0,
                                    **expected_invoice_attrs
                                  )
    end

    it 'changes Billing::InvoiceOriginatedNetwork records qty' do
      expect { subject }.to change {
        Billing::InvoiceOriginatedNetwork.count
      }.by(expected_invoice_orig_net_qty)
      expect(invoice.originated_networks.count).to eq(expected_invoice_orig_net_qty)
    end

    it 'changes Billing::InvoiceTerminatedNetwork records qty' do
      expect { subject }.to change {
        Billing::InvoiceTerminatedNetwork.count
      }.by(expected_invoice_term_net_qty)
      expect(invoice.terminated_networks.count).to eq(expected_invoice_term_net_qty)
    end

    it 'changes Billing::InvoiceOriginatedDestination records qty' do
      expect { subject }.to change {
        Billing::InvoiceOriginatedDestination.count
      }.by(expected_invoice_orig_dst_qty)
      expect(invoice.originated_destinations.count).to eq(expected_invoice_orig_dst_qty)
    end

    it 'changes Billing::InvoiceTerminatedDestination records qty' do
      expect { subject }.to change {
        Billing::InvoiceTerminatedDestination.count
      }.by(expected_invoice_term_dst_qty)
      expect(invoice.terminated_destinations.count).to eq(expected_invoice_term_dst_qty)
    end

    it 'changes Billing::InvoiceServiceData records qty' do
      expect { subject }.to change {
        Billing::InvoiceServiceData.count
      }.by(expected_srv_data_qty)
      expect(invoice.service_data.count).to eq(expected_srv_data_qty)
    end
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

  context 'with only service transactions' do
    before { stubs_generate_document }
    let!(:services) { FactoryBot.create_list(:service, 5, account:) }
    let!(:service_transactions) do
      [
        *FactoryBot.create_list(:billing_transaction, 2, service: services[0], created_at: invoice.start_date),
        FactoryBot.create(:billing_transaction, service: services[1], spent: false, created_at: invoice.end_date - 1.second),
        FactoryBot.create(:billing_transaction, service: nil, account:, created_at: invoice.start_date + 1.hour)
      ]
    end

    before do
      # not included in time interval
      FactoryBot.create_list(:billing_transaction, 5, service: services[1], created_at: invoice.start_date - 1.second)
      FactoryBot.create_list(:billing_transaction, 6, service: services[2], created_at: invoice.end_date)
      FactoryBot.create_list(:billing_transaction, 7, service: services[0], created_at: invoice.end_date + 1.hour)

      # belongs to another account
      another_acc = FactoryBot.create(:account)
      another_service = FactoryBot.create(:service, account: another_acc)
      FactoryBot.create_list(:billing_transaction, 8, service: another_service, created_at: invoice.start_date)
    end

    include_examples :fills_invoice do
      let(:expected_srv_data_qty) { 3 }
      let(:expected_invoice_attrs) do
        services_amount_spent = service_transactions[0].amount + service_transactions[1].amount + service_transactions[3].amount
        services_amount_earned = -1 * service_transactions[2].amount
        {
          services_amount_spent:,
          services_amount_earned:,
          service_transactions_count: service_transactions.size,
          amount_spent: services_amount_spent,
          amount_earned: services_amount_earned,
          amount_total: services_amount_spent - services_amount_earned
        }
      end
    end
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
