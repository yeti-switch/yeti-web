# frozen_string_literal: true

RSpec.describe BillingInvoice::Approve, type: :service do
  subject { described_class.call(service_params) }

  let(:service_params) { { invoice: } }

  context 'when valid data' do
    let!(:contractor) { FactoryBot.create(:customer) }
    let!(:contact) { FactoryBot.create(:contact, contractor:) }
    let!(:account) { FactoryBot.create(:account, contractor:, send_invoices_to: [contact.id]) }
    let(:invoice_attrs) { { account:, contractor: } }
    let!(:invoice) { FactoryBot.create(:invoice, :pending, invoice_attrs) }
    let(:invoice_document_attrs) { { invoice:, filename: "#{invoice.id}_#{invoice.start_date}_#{invoice.end_date}" } }
    let!(:invoice_document) { FactoryBot.create(:invoice_document, :filled, invoice_document_attrs) }

    before { FactoryBot.create(:smtp_connection, global: true) }

    it 'approves invoice' do
      expect { subject }.to change { invoice.state_id }.to(Billing::InvoiceState::APPROVED)
    end

    it 'enqueues email worker' do
      expect { subject }.to have_enqueued_job(Worker::SendEmailLogJob)
    end
  end

  context 'when invoice already approved' do
    let!(:invoice) { FactoryBot.build_stubbed(:invoice, :approved) }

    it 'raises error' do
      expect { subject }.to raise_error(BillingInvoice::Approve::Error, 'Invoice already approved')
    end
  end

  context 'when invoice is not approvable' do
    let!(:invoice) { FactoryBot.build_stubbed(:invoice, :new) }

    it 'raises error' do
      expect { subject }.to raise_error(BillingInvoice::Approve::Error, "Invoice can't be approved")
    end
  end

  context 'when validation error' do
    let!(:invoice) { FactoryBot.create(:invoice, :pending, :with_vendor_account) }

    before { allow_any_instance_of(Billing::Invoice).to receive(:update!).and_raise(ActiveRecord::RecordInvalid) }

    it 'raises error' do
      expect { subject }.to raise_error(BillingInvoice::Approve::Error, 'Record invalid')
    end
  end
end
