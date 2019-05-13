# frozen_string_literal: true

RSpec.describe Worker::GenerateInvoiceJob do
  describe '#perform_now' do
    subject do
      described_class.new(*job_args).perform_now
    end

    let(:job_args) do
      [
        account_id: account.id,
        start_date: '2019-04-01 00:00:00 UTC',
        end_date: '2019-05-01 00:00:00 UTC',
        invoice_type_id: Billing::InvoiceType::AUTO_FULL,
        is_vendor: true
      ]
    end

    let(:monthly_invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::MONTHLY_ID) }
    let!(:vendor) { FactoryGirl.create(:vendor) }
    let!(:account) do
      FactoryGirl.create(:account, contractor: vendor, vendor_invoice_period: monthly_invoice_period)
    end

    it 'creates invoice with correct attributes' do
      expect { subject }.to change { Billing::Invoice.count }.by(1)
      invoice = Billing::Invoice.last!
      expect(invoice).to have_attributes(
        account_id: account.id,
        start_date: Time.parse('2019-04-01 00:00:00 UTC'),
        end_date: Time.parse('2019-05-01 00:00:00 UTC'),
        type_id: Billing::InvoiceType::AUTO_FULL
      )
    end
  end
end
