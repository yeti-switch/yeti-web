# frozen_string_literal: true

RSpec.describe Jobs::Invoice, '#execute' do
  subject do
    described_class.first!.execute
  end

  shared_examples :does_not_generate_invoice do
    it 'does not call BillingInvoice::Generate' do
      expect(BillingInvoice::Generate).to_not receive(:call)
      expect { subject }.to change { Billing::Invoice.count }.by(0)
    end
  end

  shared_examples :generates_invoice do |is_vendor:|
    it 'calls BillingInvoice::Generate' do
      expect(BillingInvoice::Generate).to receive(:call).with(
        account: account,
        is_vendor: is_vendor
      ).once.and_call_original

      expect { subject }.to change { Billing::Invoice.count }.by(1)
    end
  end

  let!(:account) { FactoryBot.create(:account, *account_traits, account_attrs) }
  let(:account_traits) { [] }
  let(:account_attrs) { { contractor: contractor, max_call_duration: nil } }

  let(:config_max_call_duration) { 1_200 }
  before do
    Billing::Invoice.where(account_id: account.id).delete_all
    allow(GuiConfig).to receive(:max_call_duration).and_return(config_max_call_duration)
  end

  context 'vendor invoice' do
    let!(:contractor) { FactoryBot.create(:vendor) }
    let(:account_traits) { [:vendor_weekly] }
    let(:next_vendor_invoice_at) { Time.now }
    let(:account_attrs) do
      super().merge(
        next_vendor_invoice_at: next_vendor_invoice_at,
        next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL
      )
    end

    context 'when next_vendor_invoice_at is now' do
      include_examples :does_not_generate_invoice
    end

    context 'when config max_call_duration not passed since next_vendor_invoice_at' do
      let(:next_vendor_invoice_at) { Time.now - config_max_call_duration.seconds + 10.seconds } # now - 1_180

      include_examples :does_not_generate_invoice
    end

    context 'when config max_call_duration passed since next_vendor_invoice_at' do
      let(:next_vendor_invoice_at) { Time.now - config_max_call_duration.seconds - 10.seconds } # now - 1_210

      include_examples :generates_invoice, is_vendor: true
    end

    context 'when account max_call_duration not passed since next_vendor_invoice_at' do
      let(:next_vendor_invoice_at) { Time.now - config_max_call_duration.seconds } # now - 1_200
      let(:account_attrs) { super().merge max_call_duration: 1_300 }

      include_examples :does_not_generate_invoice
    end

    context 'when account max_call_duration passed since next_vendor_invoice_at' do
      let(:next_vendor_invoice_at) { Time.now - 1_300.seconds } # now - 1_300
      let(:account_attrs) { super().merge max_call_duration: 1_300 }

      include_examples :generates_invoice, is_vendor: true

      context 'when config max_call_duration greater than account max_call_duration' do
        let(:config_max_call_duration) { 2_400 }

        include_examples :generates_invoice, is_vendor: true
      end
    end
  end

  context 'customer invoice' do
    let!(:contractor) { FactoryBot.create(:customer) }
    let(:account_traits) { [:customer_weekly] }
    let(:next_customer_invoice_at) { Time.now }
    let(:account_attrs) do
      super().merge(
        next_customer_invoice_at: next_customer_invoice_at,
        next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL
      )
    end

    context 'when next_customer_invoice_at is now' do
      include_examples :does_not_generate_invoice
    end

    context 'when config max_call_duration not passed since next_customer_invoice_at' do
      let(:next_customer_invoice_at) { Time.now - config_max_call_duration.seconds + 10.seconds } # now - 1_180

      include_examples :does_not_generate_invoice
    end

    context 'when config max_call_duration passed since next_customer_invoice_at' do
      let(:next_customer_invoice_at) { Time.now - config_max_call_duration.seconds - 10.seconds } # now - 1_210

      include_examples :generates_invoice, is_vendor: false
    end

    context 'when account max_call_duration not passed since next_customer_invoice_at' do
      let(:next_customer_invoice_at) { Time.now - config_max_call_duration.seconds } # now - 1_200
      let(:account_attrs) { super().merge max_call_duration: 1_300 }

      include_examples :does_not_generate_invoice
    end

    context 'when account max_call_duration passed since next_customer_invoice_at' do
      let(:next_customer_invoice_at) { Time.now - 1_300.seconds } # now - 1_300
      let(:account_attrs) { super().merge max_call_duration: 1_300 }

      include_examples :generates_invoice, is_vendor: false

      context 'when config max_call_duration greater than account max_call_duration' do
        let(:config_max_call_duration) { 2_400 }

        include_examples :generates_invoice, is_vendor: false
      end
    end
  end
end
