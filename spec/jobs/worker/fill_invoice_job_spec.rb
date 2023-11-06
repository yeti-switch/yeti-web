# frozen_string_literal: true

RSpec.describe Worker::FillInvoiceJob, '#perform_now' do
  subject do
    described_class.new(*job_args).perform_now
  end

  let(:job_args) { [invoice.id] }

  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, contractor: contractor) }
  let!(:invoice) { FactoryBot.create(:invoice, :manual, account: account) }

  it 'calls BillingInvoice::Fill' do
    expect(BillingInvoice::Fill).to receive(:call).with(invoice: invoice).once.and_call_original
    expect { subject }.to_not raise_error
  end

  context 'when id is invalid' do
    let(:job_args) { [invoice.id + 1] }

    it 'calls BillingInvoice::Fill' do
      expect(BillingInvoice::Fill).to_not receive(:call)
      expect { subject }.to_not raise_error
    end
  end
end
