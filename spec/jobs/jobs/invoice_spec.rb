# frozen_string_literal: true

RSpec.describe Jobs::Invoice, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }

  shared_examples :does_not_generate_invoice do
    it 'does not call BillingInvoice::Generate' do
      expect(BillingInvoice::Generate).to_not receive(:call)
      expect { subject }.to change { Billing::Invoice.count }.by(0)
    end
  end

  shared_examples :generates_invoice do
    it 'calls BillingInvoice::Generate' do
      expect(BillingInvoice::Generate).to receive(:call).with(
        account: account
      ).once.and_call_original

      expect { subject }.to change { Billing::Invoice.count }.by(1)
    end
  end

  let!(:account) { FactoryBot.create(:account, *account_traits, account_attrs) }
  let(:account_traits) { [] }
  let(:account_attrs) do
    {
      contractor: contractor,
      max_call_duration: nil,
      next_invoice_at: next_invoice_at,
      next_invoice_type_id: Billing::InvoiceType::AUTO_FULL
    }
  end

  let(:config_max_call_duration) { 1_200 }
  before do
    Billing::Invoice.where(account_id: account.id).delete_all
    allow(GuiConfig).to receive(:max_call_duration).and_return(config_max_call_duration)
  end

  let!(:contractor) { FactoryBot.create(:vendor) }
  let(:account_traits) { [:invoice_weekly] }
  let(:next_invoice_at) { Time.now }

  context 'when next_invoice_at is now' do
    include_examples :does_not_generate_invoice
  end

  context 'when config max_call_duration not passed since next_invoice_at' do
    let(:next_invoice_at) { Time.now - config_max_call_duration.seconds + 10.seconds } # now - 1_180

    include_examples :does_not_generate_invoice
  end

  context 'when config max_call_duration passed since next_invoice_at' do
    let(:next_invoice_at) { Time.now - config_max_call_duration.seconds - 10.seconds } # now - 1_210

    include_examples :generates_invoice
  end

  context 'when account max_call_duration not passed since next_invoice_at' do
    let(:next_invoice_at) { Time.now - config_max_call_duration.seconds } # now - 1_200
    let(:account_attrs) { super().merge max_call_duration: 1_300 }

    include_examples :does_not_generate_invoice
  end

  context 'when account max_call_duration passed since next_invoice_at' do
    let(:next_invoice_at) { Time.now - 1_300.seconds } # now - 1_300
    let(:account_attrs) { super().merge max_call_duration: 1_300 }

    include_examples :generates_invoice

    context 'when config max_call_duration greater than account max_call_duration' do
      let(:config_max_call_duration) { 2_400 }

      include_examples :generates_invoice
    end
  end
end
